# Mirror Mirror

Mirror one monitor to another using `wl-mirror` on Hyprland, Sway, and Niri.
Monitor selection is automatic and always up-to-date, powered by Quickshell's screen management.

## Features

- Bar icon opens a panel for monitor selection.
- Select source monitor and destination monitor from detected connected outputs.
- Starts `wl-mirror` in fullscreen destination mode so the source is scaled to destination.
- Stop mirroring from the same panel.
If fewer than 2 monitors are detected, monitor selectors and mirror actions are disabled.

## Dependencies

Install the following package:

- `wl-mirror`



## Usage

1. Add the plugin to the bar.
2. Click the plugin icon.
3. Choose source and destination monitors.
4. Click **Start mirror**.
5. Click **Stop mirror** to end mirroring.

## Credits

- Original plugin by **Mathew-D**
- Contributor: **sima** (`@kevichi7`) - fixed the monitor source and destination dropdown selection bug

