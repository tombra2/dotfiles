# DDEV Projects

A Herd-style bar widget for managing local [DDEV](https://ddev.com/) projects from the Omarchy bar — start/stop projects, open a database admin tool, check sent email, and scaffold new WordPress sites, without leaving the bar.

## Install

```sh
omarchy plugin add https://github.com/sanjayatony/omarchy-ddev-projects.git --enable
```

Choose a bar section when prompted (right is the default).

## Usage

Click the server-rack icon in the bar to open the panel. It lists every project `ddev list` knows about, refreshing automatically every few seconds while open.

Each project row shows:

- A status dot (accent = running, muted = stopped) and an uncommitted-changes warning badge when a running project's git repo is dirty.
- **Open in browser** — opens the project's primary URL.
- **Mailpit** — opens the project's Mailpit inbox (sent emails), no extra setup required.
- **DB Admin** — opens [Adminer](https://www.adminer.org/) for the project's database. On first use per project this installs the `ddev/ddev-adminer` add-on and restarts that project's containers; subsequent clicks just open the browser.
- **Start / Stop** — runs `ddev start` / `ddev stop` for that project.

At the top of the panel, **New WordPress Site** creates a fresh WordPress install at a path you choose (defaults to `~/Work/`): it runs `ddev config`, `ddev start`, `ddev wp core download`, and `ddev wp core install`, then shows the login (`admin` / `admin`) until you hit refresh.

## Configuration

No configuration file — the panel always reflects live `ddev list` output. There's nothing to set in `shell.json` beyond the widget's placement (`omarchy bar move tony.ddev-projects --section <left|center|right>`).

## Notes

- Every `ddev`/`docker` action the panel runs is wrapped in a `timeout`, with a background watchdog as a second safety net, so a hung command can't permanently disable the panel's buttons.
- DB Admin and site creation both invoke `ddev`/Docker directly and can restart or create containers — expected DDEV behavior, not a bug.
- Change the WordPress admin credentials in `Panel.qml`'s `createSite()` if you don't want the `admin`/`admin` default.

## Removal

```sh
omarchy plugin remove tony.ddev-projects
```

This only removes the plugin — it does not touch any DDEV projects, containers, or data.
