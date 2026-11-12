#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

name="$(sed -n 's/^id = "\(.*\)"/\1/p' plugin.toml | head -n1)"
version="$(sed -n 's/^version = "\(.*\)"/\1/p' plugin.toml | head -n1)"

if [[ -z "$name" || -z "$version" ]]; then
    echo "Could not read id/version from plugin.toml" >&2
    exit 1
fi

mkdir -p dist
archive="dist/${name}-${version}.zip"
rm -f "$archive"

zip -r -X "$archive" \
    plugin.toml \
    main.lua \
    files.txt \
    wallhaven_plus

echo "Built $archive"
