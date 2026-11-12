# Wallhaven Plus Plugin for Waywallen

Wallhaven Plus is an unofficial source plugin for
[Waywallen](https://github.com/waywallen/waywallen). It adds a second Wallhaven
source to Discover with more sort options, category filters, and collection
browsing. The bundled Wallhaven plugin stays untouched, so you can keep both
installed and switch between them.

## What it adds

Sort modes: Recent (the default), Trending for the last month, Top 3 months,
Top 6 months, Top 1 year, Most viewed, Most favorited, Hot, and Random. Random
keeps the same ordering while you page through results.

The search box accepts Wallhaven's query syntax: `+tag`, `-tag`, `@username`,
`id:123`, `type:jpg`, and `like:<wallpaper id>`.

Filters:

- Categories: General, Anime, People.
- Purity: Safe for work, Suggestive (Sketchy), Explicit (NSFW).
- Topics, including Celebrities, Models, and Cosplay.
- Exact resolution.

Collections: type `collection:<username>/<id>` in the search box to open a
public collection. With an API key you can open your own private collections.

Suggestive (Sketchy) results work without a key. Explicit NSFW results and
private collections need a Wallhaven API key.

## Requirements

Waywallen 0.6.0 or newer. The plugin uses `entry_version = 4`.

A Wallhaven account is only needed for NSFW results and private collections.

## Install

### From the ZIP

Download the latest `org.julia.wallhaven-plus-<version>.zip` from the
[Releases](https://github.com/julsales/waywallen-wallhaven-plus/releases) page,
or build it locally:

```bash
./scripts/build.sh
```

Then open Waywallen, go to **Plugins**, choose **Install from ZIP**, and pick
the ZIP.

### From the repository

Copy the plugin into the user plugin directory:

```bash
mkdir -p ~/.local/share/waywallen/plugins/org.julia.wallhaven-plus
cp -a plugin.toml main.lua files.txt LICENSE wallhaven_plus \
  ~/.local/share/waywallen/plugins/org.julia.wallhaven-plus/
systemctl --user restart app-org.waywallen.waywallen@autostart.service
```

Then reopen the UI from the tray icon, or run:

```bash
gdbus call --session \
  --dest org.waywallen.waywallen.Daemon \
  --object-path /org/waywallen/waywallen/Daemon \
  --method org.waywallen.waywallen.Daemon1.OpenUi
```

## Use

Open **Discover**, select **Wallhaven Plus**, then pick a sort and any filters.
The search box works with an empty query or with Wallhaven syntax.

For collections, open the collection on Wallhaven and copy the username and
numeric id from the URL:

```
https://wallhaven.cc/user/<username>/collections/<id>
```

Then search for:

```
collection:<username>/<id>
```

To use an API key, open **Plugins**, select **Wallhaven Plus**, and choose
**Log in to Wallhaven**. Paste the API key from your Wallhaven account settings.
Do not enter your password.

## Notes

Wallhaven returns 24 items per page. Scroll to the end to load more.

The plugin opens on Recent. Switch to Trending or one of the Top modes to see
popular wallpapers instead of new ones.

Explicit NSFW results need an API key. Suggestive results do not. Without a key,
the plugin can show SFW and Sketchy wallpapers.

Wallhaven limits API calls to 45 per minute. The plugin does not retry on its
own. If you hit the limit, wait a minute and search again.

## Security

Waywallen plugins run Lua inside the daemon with your user account's
permissions. They can read and write files and use the network. Read the code
before installing a third-party plugin.

This plugin calls the Wallhaven API at `wallhaven.cc`; Waywallen downloads the
wallpaper files from the URLs the API returns. The API key is kept in
Waywallen's plugin lifecycle storage, not in this repository. When you delete a
downloaded wallpaper, the plugin removes that file and its metadata JSON.

This project is not affiliated with Waywallen or Wallhaven.

## Development

The source is plain Lua. `scripts/build.sh` packages the files listed in
`files.txt` into the ZIP that the plugin installer expects.

```
plugin.toml          manifest (id, entry, entry_version)
main.lua             plugin info, actions, lifecycle wiring
wallhaven_plus/      API client, mapping, discover/source/wallpaper modules
files.txt            files included in the package
scripts/build.sh     builds dist/org.julia.wallhaven-plus-<version>.zip
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for local testing and pull request
notes.

References:

- Waywallen: <https://github.com/waywallen/waywallen>
- Bundled Wallhaven plugin: `plugins/org.waywallen.wallhaven`
- Wallhaven API: <https://wallhaven.cc/help/api>

## License

MIT. See [LICENSE](LICENSE).
