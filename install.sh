#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/Projects/zed-config"
ZED_DOTFILES="$DOTFILES_DIR/zed"
ZED_CONFIG="$HOME/.config/zed"

mkdir -p "$ZED_CONFIG"

backup_if_real_file() {
  local target="$1"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
  fi
}

backup_if_real_file "$ZED_CONFIG/settings.json"
backup_if_real_file "$ZED_CONFIG/keymap.json"
backup_if_real_file "$ZED_CONFIG/snippets"
backup_if_real_file "$ZED_CONFIG/themes"

ln -sf "$ZED_DOTFILES/settings.json" "$ZED_CONFIG/settings.json"
ln -sf "$ZED_DOTFILES/keymap.json" "$ZED_CONFIG/keymap.json"

ln -sfn "$ZED_DOTFILES/snippets" "$ZED_CONFIG/snippets"
ln -sfn "$ZED_DOTFILES/themes" "$ZED_CONFIG/themes"

echo "Zed config installed successfully."
echo "Restart Zed if themes or snippets do not appear immediately."