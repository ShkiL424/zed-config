#!/usr/bin/env bash
set -euo pipefail

# Resolve the repo root from the script location so the repo can live anywhere.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZED_DOTFILES="$DOTFILES_DIR/zed"
ZED_CONFIG="$HOME/.config/zed"

mkdir -p "$ZED_CONFIG"

backup_if_real_file() {
  local target="$1"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
  fi
}

install_link() {
  local name="$1"
  local source="$ZED_DOTFILES/$name"
  local target="$ZED_CONFIG/$name"

  if [ ! -e "$source" ]; then
    echo "Skipping $name: not found in $ZED_DOTFILES" >&2
    return
  fi

  backup_if_real_file "$target"
  # -n: replace an existing symlink to a directory instead of descending into it.
  ln -sfn "$source" "$target"
  echo "Linked $target -> $source"
}

install_link settings.json
install_link keymap.json
install_link tasks.json
install_link snippets
install_link themes

echo "Zed config installed successfully."
echo "Restart Zed if themes or snippets do not appear immediately."
