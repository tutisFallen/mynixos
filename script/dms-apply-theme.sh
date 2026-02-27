#!/usr/bin/env sh
DMS_DIR="$HOME/.config/DankMaterialShell"
ICON_FILE="$DMS_DIR/icon-theme"
CUR_FILE="$DMS_DIR/cursor-theme"

# Verifica se gsettings está disponível
if ! command -v gsettings >/dev/null 2>&1; then
    echo "Erro: gsettings não encontrado." >&2
    exit 1
fi

[ -r "$ICON_FILE" ] && ICON=$(cat "$ICON_FILE") || ICON=""
[ -r "$CUR_FILE" ] && CUR=$(cat "$CUR_FILE") || CUR=""

if [ -n "$ICON" ]; then
    gsettings set org.gnome.desktop.interface icon-theme "$ICON"
fi

if [ -n "$CUR" ]; then
    gsettings set org.gnome.desktop.interface cursor-theme "$CUR"
fi