# Wallhaven Plus for Waywallen

A third-party [Waywallen](https://github.com/waywallen/waywallen) source plugin
that brings more of the Wallhaven API into the Discover view.

It is a drop-in alternative to the bundled Wallhaven plugin. You can keep both
installed: the bundled one appears as **Wallhaven**, this one as
**Wallhaven Plus**.

## Features

- **More sort modes**
  - Trending (top of the last month)
  - Top 3 months / 6 months / 1 year
  - Recent (latest uploads)
  - Most viewed
  - Most favorited
  - Hot
  - Random (with a stable seed across pages)
- **Full Wallhaven search syntax** in the search box:
  - `+tag` / `-tag`
  - `@username`
  - `id:123`
  - `type:jpg`
  - `like:<wallpaper id>`
- **Collections**: type `collection:<username>/<id>` in the search box to browse
  the wallpapers of a public collection. With an API key you can also open your
  own private collections.
- **API key login** for NSFW results and private collections.
- **Filters**: purity, topics (any/all), and exact resolution.

## Requirements

- Waywallen **0.6.0 or newer** (plugin `entry_version = 4`).
- A Wallhaven account only if you want NSFW results or private collections.

## Install

### From a ZIP

```bash
./scripts/build.sh
```

Then open Waywallen → **Plugins** → **Install from ZIP** and choose
`dist/org.julia.wallhaven-plus-0.1.0.zip`.

### Development copy

Copy (or symlink) this directory into the user plugin directory:

```bash
mkdir -p ~/.local/share/waywallen/plugins
ln -sfn "$PWD" ~/.local/share/waywallen/plugins/org.julia.wallhaven-plus
systemctl --user restart app-org.waywallen.waywallen@autostart.service
```

Reopen the UI from the tray or with `waywallen --new-window`? No — use the
Waywallen tray icon, or ask the daemon:

```bash
gdbus call --session \
  --dest org.waywallen.waywallen.Daemon \
  --object-path /org/waywallen/waywallen/Daemon \
  --method org.waywallen.waywallen.Daemon1.OpenUi
```

## Usage

1. Open **Discover** and select **Wallhaven Plus** as the source.
2. Pick a sort mode and (optionally) filters.
3. Type a query, or use the Wallhaven syntax. Leave it empty for a general
   listing.
4. Open an item to see details, download it, and apply it.

### Collections

Wallhaven collection URLs look like:

```
https://wallhaven.cc/user/<username>/collections/<id>
```

Use the same username and numeric id in the search box:

```
collection:<username>/<id>
```

For private collections, add your API key in the plugin settings first.

### API key

Waywallen → Plugins → **Wallhaven Plus** → **Log in to Wallhaven**. Paste the
API key from your Wallhaven account settings. Do **not** enter your password.

## Notes

- Wallhaven returns **24 items per page**. Keep scrolling (or use "load more")
  to fetch the next pages.
- The default sort is **Trending (1 month)**, which is the top of the last
  month — not the whole site. Use **Recent** to see every new upload.
- NSFW results require an API key. Without one, only SFW results are returned.
- The plugin talks directly to `https://wallhaven.cc/api/v1` and follows the
  public API rate limit (45 requests/minute).

## Security

Third-party Waywallen plugins run Lua inside the daemon with your user account's
privileges. They can read and write files and access the network. Review the
code before installing, and only install plugins you trust.

This plugin only performs HTTP requests to `wallhaven.cc` and stores the API key
through Waywallen's own plugin lifecycle storage. It does not read or write
unrelated files.

## Development

The plugin is plain Lua. There is no build step for the source itself; the build
script only packages the ZIP understood by the Waywallen plugin installer.

```
plugin.toml          manifest (id, entry, entry_version)
main.lua             plugin info, actions, lifecycle wiring
wallhaven_plus/      API client, mapping, discover/source/wallpaper modules
files.txt            file list used by the installer
scripts/build.sh     packages dist/org.julia.wallhaven-plus-<version>.zip
```

Useful references:

- Waywallen plugin system: <https://github.com/waywallen/waywallen>
- Official Wallhaven plugin: `plugins/org.waywallen.wallhaven`
- Wallhaven API: <https://wallhaven.cc/help/api>

## License

MIT. See [LICENSE](LICENSE).
