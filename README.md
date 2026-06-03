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

Run the install script to symlink the config files into `~/.config/zed`:

```bash
./install.sh
```

The script will:
- Back up any existing real files (non-symlinks) with a timestamped `.backup` suffix
- Create symlinks from `~/.config/zed` to this repo

## Requirements

- macOS or Linux
- [Zed editor](https://zed.dev) installed

## Notes

After running `install.sh`, restart Zed if themes or snippets do not appear immediately.
