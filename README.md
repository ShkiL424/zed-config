# zed-config

Configuration for [Zed](https://zed.dev) IDE, managed as a dotfiles repo with symlinks.

## Structure

```
zed/
├── settings.json   # Editor settings
├── keymap.json     # Custom keybindings
├── tasks.json      # Task runner definitions
├── snippets/       # Code snippets
└── themes/         # Custom themes
```

## Installation

### macOS / Linux

Run the install script to symlink the config files into `~/.config/zed`:

```bash
./install.sh
```

The script will:
- Back up any existing real files (non-symlinks) with a timestamped `.backup` suffix
- Create symlinks from `~/.config/zed` to this repo

### Windows

1. Enable Developer Mode: **Settings > System > For developers > Developer Mode**.
   Without it (or an Administrator shell) Windows does not allow creating file symlinks.
2. Clone the repo and go to its root:

   ```powershell
   git clone <repo-url> $HOME\Projects\zed-config
   cd $HOME\Projects\zed-config
   ```

3. Run the install script:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

   `-ExecutionPolicy Bypass` applies only to this run and does not change system settings.
4. Restart Zed.

If Developer Mode cannot be enabled, run steps 2–3 in PowerShell opened with **Run as Administrator**.

The script links config into `%APPDATA%\Zed`: files as symlinks, directories as junctions.
Existing real files are backed up with a timestamped `.backup` suffix, same as on macOS.

To verify the result:

```powershell
Get-ChildItem $env:APPDATA\Zed | Select-Object Name, LinkType, Target
```

`settings.json` and `keymap.json` should show `SymbolicLink`, `snippets` should show `Junction`.

> Note: keybindings using `cmd` map to the Windows key on Windows, so some of them may be intercepted by the OS.
> Tasks in `tasks.json` use `sh` and `python3`, which are usually not available on Windows.

## Requirements

- macOS, Linux, or Windows (PowerShell 5.1+)
- [Zed editor](https://zed.dev) installed

## Notes

After running the install script, restart Zed if themes or snippets do not appear immediately.
