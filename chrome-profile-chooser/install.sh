#!/bin/sh
set -eu
cd "$(dirname "$0")"
data_dir=${XDG_DATA_HOME:-"$HOME/.local/share"}
handler="$data_dir/chrome-profile-chooser/open-link"
desktop="$data_dir/applications/chrome-profile-chooser.desktop"
install -Dm755 open-link "$handler"
mkdir -p "$(dirname "$desktop")"
cat > "$desktop" <<ENTRY
[Desktop Entry]
Type=Application
Name=Chrome Profile Chooser
Icon=com.google.Chrome
Exec=/usr/bin/python3 "$handler" %u
Terminal=false
NoDisplay=true
MimeType=x-scheme-handler/http;x-scheme-handler/https;
ENTRY
desktop-file-validate "$desktop"
update-desktop-database "$(dirname "$desktop")"
for scheme in http https; do
    xdg-mime default chrome-profile-chooser.desktop "x-scheme-handler/$scheme"
done
