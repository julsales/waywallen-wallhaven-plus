# Contributing

This is a small third-party plugin, so keep changes focused and easy to review.

## Before you start

- The plugin targets Waywallen 0.6.0+ and plugin `entry_version = 4`. If you
  test against another version, say which one in the pull request.
- The source is Lua and runs inside Waywallen's sandbox. Avoid new
  dependencies and host-specific code.
- Do not commit API keys, downloaded wallpapers, or local test data.

## Run it locally

Copy the plugin into the user plugin directory:

```bash
mkdir -p ~/.local/share/waywallen/plugins/org.julia.wallhaven-plus
cp -a plugin.toml main.lua files.txt LICENSE wallhaven_plus \
  ~/.local/share/waywallen/plugins/org.julia.wallhaven-plus/
systemctl --user restart app-org.waywallen.waywallen@autostart.service
```

Reopen the UI from the tray icon, or run:

```bash
gdbus call --session \
  --dest org.waywallen.waywallen.Daemon \
  --object-path /org/waywallen/waywallen/Daemon \
  --method org.waywallen.waywallen.Daemon1.OpenUi
```

Check that the daemon loaded the plugin:

```bash
journalctl --user -b 0 --since "2 minutes ago" |
  grep -iE "wallhaven_plus|error|skip"
```

You should see `loaded source plugin: wallhaven_plus`. If the plugin does not
appear, fix the log error before testing the UI.

## What to test

- The plugin loads without errors.
- Discover lists Wallhaven Plus as a source.
- Every sort returns results: Recent, Trending, Top 3 months, Top 6 months,
  Top 1 year, Most viewed, Most favorited, Hot, Random.
- Categories: General, Anime, People.
- Purity: Safe for work, Suggestive (Sketchy), and Explicit (NSFW) with a key.
  Without a key, NSFW should show an error and Sketchy should still work.
- Topics and exact resolution filters.
- Collection browsing with a public collection.
- Pagination: scroll to the second page and confirm the results change.
- API key sign-in and sign-out, including the status text.

## Code layout

```
plugin.toml          manifest and plugin id
main.lua             info(), actions, lifecycle wiring
wallhaven_plus/
  api.lua            HTTP requests and Wallhaven query building
  discover.lua       search, details, download
  map.lua            API response mapping
  session.lua        API key storage and validation
  source.lua         item removal
  wallpaper.lua      apply downloaded wallpapers
files.txt            files included in the release ZIP
scripts/build.sh     packaging
```

## Style

- Keep the module split. API requests belong in `api.lua`, response mapping in
  `map.lua`, and UI-facing behavior in `discover.lua`.
- Keep error messages short and tell the user what to do next.
- Send the API key in the `X-API-Key` header. Never put it in a URL or a log.
- Validate values that go into URLs or file paths.
- Keep Lua 5.1 and 5.4 compatibility. The app uses `mlua`.
- Do not add telemetry, analytics, or requests to hosts other than the
  Wallhaven API.

## Packaging

```bash
./scripts/build.sh
```

The ZIP is written to `dist/`. In Waywallen, open **Plugins**, choose
**Install from ZIP**, and confirm the plugin still loads. `files.txt` drives
the package contents, so add any new runtime file there.

## Pull requests

- Keep each pull request focused on one change.
- Include what you tested and the Waywallen version you used.
- Update `README.md` when behavior or filters change.
- Do not bump the plugin version in a feature pull request. The maintainer
  handles versioning at release time.

## Security

Use GitHub's private vulnerability reporting for security issues: open the
repository's **Security** tab, then **Report a vulnerability**. Do not open a
public issue with an API key, a private collection URL, or other personal data.

## License

By contributing, you agree that your changes are licensed under the MIT
License in [LICENSE](LICENSE).
