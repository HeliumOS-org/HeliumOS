#!/usr/bin/env sh


set -xeuo pipefail

rm -rf \
    /usr/share/plasma/look-and-feel/org.fedoraproject.fedora.desktop
rm -rf \
    /usr/share/wallpapers/fedora
rm -rf \
    /usr/share/wallpapers/Fedora
rm -rf \
    /usr/share/wallpapers/F4*
rm -rf \
    /usr/share/backgrounds/*

sed -i 's,AlmaLinux,HeliumOS,g' \
    /usr/lib/os-release
sed -i 's,10.1,10,g' \
    /usr/lib/os-release
sed -i 's, (Heliotrope Lion),,g' \
    /usr/lib/os-release
sed -i 's,ID="almalinux",ID="heliumos",g' \
    /usr/lib/os-release
sed -i 's,rhel,almalinux rhel,g' \
    /usr/lib/os-release
sed -i 's,0;34,38;5;39,g' \
    /usr/lib/os-release
sed -i 's,cpe:/o:almalinux:almalinux:10::baseos,cpe:/o:heliumos:heliumos:10::baseos,g' \
    /usr/lib/os-release
sed -i 's,https://almalinux.org/,https://www.heliumos.org/,g' \
    /usr/lib/os-release
sed -i 's,https://wiki.almalinux.org/,https://www.heliumos.org/docs,g' \
    /usr/lib/os-release
sed -i 's,AlmaLinux,HeliumOS,g' \
    /usr/lib/os-release
sed -i 's,https://bugs.almalinux.org/,https://bugs.heliumos.org/,g' \
    /usr/lib/os-release
sed -i 's, (Lion Cub),,g' \
    /usr/lib/os-release

curl \
    -o logo.tar.gz \
    https://codeberg.org/HeliumOS/logo/archive/0ce8b5cd8f6d311924d84c9a9f4961da95306171.tar.gz
tar -xzf \
    logo.tar.gz
mv \
    logo/export/logo/logo-color.svg \
    /usr/share/icons/hicolor/scalable/apps/heliumos-logo-icon.svg
mv \
    logo/export/logo/logo.svg \
    /usr/share/icons/hicolor/scalable/apps/heliumos-logo-icon-white.svg
mv \
    logo/export/logo/logo-color-256x256.png \
    /usr/share/icons/hicolor/256x256/apps/heliumos-logo-icon.png
mv \
    logo/export/logo/logo-color-64x64.png \
    /usr/share/icons/hicolor/64x64/apps/heliumos-logo-icon.png
ln -sf \
    /usr/share/icons/hicolor/scalable/apps/heliumos-logo-icon.svg \
    /usr/share/icons/hicolor/scalable/apps/start-here.svg
ln -sf \
    /usr/share/icons/hicolor/scalable/apps/heliumos-logo-icon.svg \
    /usr/share/icons/hicolor/scalable/apps/xfce4_xicon1.svg
ln -sf \
    /usr/share/icons/hicolor/scalable/apps/heliumos-logo-icon.svg \
    /usr/share/pixmaps/fedora-logo-sprite.svg
ln -sf \
    /usr/share/icons/hicolor/256x256/apps/heliumos-logo-icon.png \
    /usr/share/pixmaps/fedora-logo-sprite.png
ln -sf \
    /usr/share/icons/hicolor/256x256/apps/heliumos-logo-icon.png \
    /usr/share/pixmaps/fedora-logo.png
ln -sf \
    /usr/share/icons/hicolor/256x256/apps/heliumos-logo-icon.png \
    /usr/share/pixmaps/system-logo-white.png
ln -sf \
    /usr/share/icons/hicolor/64x64/apps/heliumos-logo-icon.png \
    /usr/share/pixmaps/fedora-gdm-logo.png
ln -sf \
    /usr/share/icons/hicolor/64x64/apps/heliumos-logo-icon.png \
    /usr/share/pixmaps/fedora-logo-small.png


declare -a plasma_themes=("breeze" "breeze-dark")
declare -a icon_sizes=("16" "22" "32" "64" "96")
declare -a start_here_variants=("start-here-kde-plasma.svg" "start-here-kde.svg" "start-here-kde-plasma-symbolic.svg" "start-here-kde-symbolic.svg" "start-here-symbolic.svg")
for plasma_theme in "${plasma_themes[@]}"
do
    for icon_size in "${icon_sizes[@]}"
    do
        for start_here_variant in "${start_here_variants[@]}"
        do
                ln -sf \
                    /usr/share/icons/hicolor/scalable/apps/heliumos-logo-icon.svg \
                    /usr/share/icons/${plasma_theme}/places/${icon_size}/${start_here_variant}
        done
    done
done

curl \
    -o wallpapers.tar.gz \
    https://codeberg.org/HeliumOS/wallpapers/archive/eccec97df37d4d5aee4f23e1e57b46c0e4e6c484.tar.gz
tar -xzf \
    wallpapers.tar.gz \
    -C /workdir
mkdir -p \
    /usr/share/wallpapers/Andromeda/contents/images
cp \
    /workdir/wallpapers/andromeda.jpg \
    /usr/share/wallpapers/Andromeda/contents/images/5338x5905.jpg

cat <<EOF >>/usr/share/wallpapers/Andromeda/metadata.json
{
    "KPlugin": {
        "Authors": [
            {
                "Name": "HeliumOS"
            }
        ],
        "Id": "Andromeda",
        "Name": "Andromeda"
    }
}
EOF


declare -a lookandfeels=("org.kde.breeze.desktop" "org.kde.breezedark.desktop" "org.kde.breezetwilight.desktop")
for lookandfeel in "${lookandfeels[@]}"
do
    sed -i \
        's,Image=Next,Image=Andromeda,g' \
        /usr/share/plasma/look-and-feel/${lookandfeel}/contents/defaults
done

ln -s \
    /usr/share/wallpapers/Andromeda/contents/images/5338x5905.jpg \
    /usr/share/backgrounds/default.png

dnf remove -y \
    console-login-helper-messages

rm -rf \
    /var/run

rm /branding.sh
