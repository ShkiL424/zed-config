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
- Create symlinks from `~/.config/zed` to this repo (`settings.json`, `keymap.json`, `tasks.json`, `snippets/`, `themes/`)

The repo can be cloned anywhere: the script resolves paths relative to its own location.

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

`settings.json`, `keymap.json` and `tasks.json` should show `SymbolicLink`, `snippets` and `themes` should show `Junction`.

> Notes for Windows:
> - Panel shortcuts use `secondary-` (Cmd on macOS, Ctrl on Windows/Linux). `cmd-g` (Git panel) stays macOS-only:
>   on Windows `cmd` is the Windows key, and `Win+G` is taken by the Xbox Game Bar.
> - The `r/python` task calls `python3`; on Windows install Python from python.org or use the `py` launcher.

## Requirements

- macOS, Linux, or Windows (PowerShell 5.1+)
- [Zed editor](https://zed.dev) installed

The config expects these to be installed, otherwise Zed falls back to defaults:

| What | Used by | How to install |
| --- | --- | --- |
| **One Dark Pro Vivid** theme | `theme`, `theme_overrides` | Zed extension (`zed: extensions`) |
| **Material Icon Theme** | `icon_theme` | Zed extension |
| **JetBrains Mono** font | UI, editor, terminal, Markdown preview | [jetbrains.com/mono](https://www.jetbrains.com/lp/mono/) or `brew install --cask font-jetbrains-mono` |
| `ruff`, `pyright` | Python formatting and linting | `pip install ruff pyright` (or via `uv tool`) |
| Node.js (`npx`) | Context7 MCP server | [nodejs.org](https://nodejs.org) or nvm |
| GitHub Copilot sign-in | Edit predictions | Sign in from Zed when prompted |
| `cargo`, `python3`, `docker` | Tasks in `tasks.json` | Only if you use those tasks |

## Context7 API key

The Context7 MCP server reads its API key from the `CONTEXT7_API_KEY` environment variable.
Do not put the key into `settings.json`: it is a symlink into this repo, so the key would end up in git.

macOS / Linux: add to `~/.zshrc` (or `~/.bashrc`) and restart Zed:

```bash
export CONTEXT7_API_KEY="ctx7sk-..."
```

Windows (PowerShell), then restart Zed:

```powershell
[Environment]::SetEnvironmentVariable('CONTEXT7_API_KEY', 'ctx7sk-...', 'User')
```

Without the key Context7 still works, with lower anonymous rate limits.

## Validation

GitHub Actions (`.github/workflows/validate.yml`) checks every push and pull request:
JSON-with-comments syntax of `zed/**/*.json`, `bash -n` and `shellcheck` for `install.sh`, and PowerShell syntax of `install.ps1`.
Run the JSON check locally with:

```bash
python3 .agents/skills/land/scripts/check-jsonc.py zed/*.json zed/snippets/*.json
```

## Notes

After running the install script, restart Zed if themes or snippets do not appear immediately.
