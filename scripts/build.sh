#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

name="$(sed -n 's/^id = "\(.*\)"/\1/p' plugin.toml | head -n1)"
version="$(sed -n 's/^version = "\(.*\)"/\1/p' plugin.toml | head -n1)"

if [[ -z "$name" || -z "$version" ]]; then
    echo "Could not read id/version from plugin.toml" >&2
    exit 1
fi

if [[ ! "$name" =~ ^[A-Za-z0-9._+-]+$ || ! "$version" =~ ^[A-Za-z0-9._+-]+$ ]]; then
    echo "Refusing unsafe id/version in plugin.toml" >&2
    exit 1
fi

stage="$(mktemp -d "${TMPDIR:-/tmp}/wallhaven-plus.XXXXXX")"
trap 'rm -rf -- "$stage"' EXIT

# Package exactly the files the installer is told to expect. This keeps
# editor backups, local notes, and symlinks out of the release ZIP.
while IFS= read -r file; do
    file="${file%$'\r'}"
    [[ -z "$file" ]] && continue
    case "$file" in
        /*|-*|..|../*|*/../*|*/..)
            echo "files.txt contains an unsafe path: $file" >&2
            exit 1
            ;;
    esac
    if [[ -L "$file" ]]; then
        echo "files.txt must not contain symlinks: $file" >&2
        exit 1
    fi
    parent="$file"
    while [[ "$parent" == */* ]]; do
        parent="${parent%/*}"
        if [[ -L "$parent" ]]; then
            echo "files.txt path traverses a symlink: $file" >&2
            exit 1
        fi
    done
    if [[ ! -f "$file" ]]; then
        echo "files.txt lists a missing or non-regular file: $file" >&2
        exit 1
    fi
    dir="${file%/*}"
    if [[ "$dir" == "$file" ]]; then
        dir="."
    fi
    mkdir -p "$stage/$dir"
    cp "$file" "$stage/$file"
done < files.txt

# files.txt is required by the installer even though it conventionally does
# not list itself.
cp files.txt "$stage/files.txt"

# Catch a module that was added to the tree but forgotten in files.txt.
while IFS= read -r file; do
    if ! grep -Fqx -- "$file" files.txt; then
        echo "files.txt is missing $file" >&2
        exit 1
    fi
done < <(find wallhaven_plus -type f -name '*.lua' | sort)

for required in plugin.toml main.lua; do
    if ! grep -Fqx -- "$required" files.txt; then
        echo "files.txt is missing $required" >&2
        exit 1
    fi
done

# Do not ship group/world-writable plugin code from the archive.
find "$stage" -type d -exec chmod 755 {} +
find "$stage" -type f -exec chmod 644 {} +

mkdir -p dist
archive="$PWD/dist/${name}-${version}.zip"
rm -f "$archive"

(
    cd "$stage"
    zip -r -X "$archive" .
)

echo "Built $archive"
