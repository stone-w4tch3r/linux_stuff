# shellcheck shell=bash
# shellcheck disable=SC2317

return 0

####
#init
####
sudo apt update && sudo apt upgrade -y && sudo apt install neofetch -y
sudo apt purge --autoremove -y libreoffice\*
#kde
sudo apt purge --autoremove -y ktorrent kmines ksudoku kmahjongg

####
#apps
####

sudo apt install git curl network-manager-openvpn network-manager-sstp net-tools fortune cowsay silversearcher-ag libreoffice-\*-nogui exfatprogs -y
sudo apt install -y vlc qbittorrent
sudo snap install rider --classic
sudo snap install webstorm --classic
sudo snap install datagrip --classic
sudo snap install pycharm-professional --classic
sudo snap install multipass
#bitwarden

flatpak install com.discordapp.Discord com.mattermost.Desktop org.telegram.desktop us.zoom.Zoom

####
# flatpak IDEs
####

# download host-spawn and use it as shell executable https://github.com/1player/host-spawn
wget https://github.com/1player/host-spawn/releases/latest/download/host-spawn-x86_64
mv host-spawn-x86_64 ~/.local/bin/
chmod +x ~/.local/bin/host-spawn-x86_64

# rider
flatpak install flathub com.jetbrains.Rider
flatpak install org.freedesktop.Sdk.Extension.dotnet8 # SDK
flatpak override --user com.jetbrains.Rider --env=FLATPAK_ENABLE_SDK_EXT="dotnet8" # enable dotnet for rider

# webstorm
flatpak install flathib com.jetbrains.WebStorm
flatpak install org.freedesktop.Sdk.Extension.node22
flatpak override --user com.jetbrains.WebStorm --env=FLATPAK_ENABLE_SDK_EXT="node22"

# continue config access:
flatpak override --user com.jetbrains.WebStorm --filesystem=home/.continue

####
#setup zram
####

lsblk #list all partitions (including swap)
cat /proc/swaps #check if zram is enebled
sudo nano /etc/fstab #comment out line with swap device
sudo swapoff -a #disable all swaps
sudo apt install zram-config
sudo reboot #after reboot zram will be enabled

sudo nano /usr/bin/init-zram-swapping #edit zram configuration
#edit calculation to replace '/ 2' with '/4', '/8' or something else
#add 'echo lz4 > /sys/block/zram0/comp_algorithm' under 'mem=$' line to use lz4 compression
sudo reboot

####
#setup apple wireless keyboard
####

#connect keyboard first, or reboot later

#install patched kernel module, see https://wiki.archlinux.org/title/Apple_Keyboard
sudo apt install dkms -y

git clone https://github.com/free5lot/hid-apple-patched
cd hid-apple-patched

sudo dkms add .
sudo dkms build hid-apple/1.0
sudo dkms install hid-apple/1.0

#set setting for keyboard:
sudo tee /etc/modprobe.d/hid_apple.conf <<EOF
options hid_apple iso_layout=0
options hid_apple fnmode=2
options hid_apple swap_fn_leftctrl=1
options hid_apple swap_opt_cmd=1
#options hid_apple rightalt_as_rightctrl=1
#options hid_apple ejectcd_as_delete=1
EOF

#apply config: ubuntu
sudo update-initramfs -u
# fedora:
sudo dracut -f


sudo modprobe -r hid_apple; sudo modprobe hid_apple

#for remapping eject to delete, 'Input Remapper' can be used
sudo apt install input-remapper -y

#fedora:
sduo dnf install -y input-remapper
sudo systemctl enable input-remapper

####
#install java jre for xamarin-android
####
sudo apt install openjdk-11-jdk -y
readlink -f $(which java) #get path to jre

####
#install firefox as deb
####
sudo snap remove firefox
sudo add-apt-repository ppa:mozillateam/ppa

#setup ppa priority
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap1-0ubuntu2
Pin-Priority: -1
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

#configure updates
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

sudo apt install firefox

####
#firefox dev
####

flatpak install --noninteractive https://gitlab.com/projects261/firefox-dev-flatpak/-/raw/main/firefox-dev.flatpakref

####
#script for automatic installation/removing of firefox
####

#in case firefox will have problems, complete purging can be performed via this script
git clone https://gitlab.com/Linux-Is-Best/Firefox-automatic-install-for-Linux.git
cd Firefox-automatic-install-for-Linux
chmod +x Setup.sh
./Setup.sh

####
#enable wayland for firefox
####
echo 'MOZ_ENABLE_WAYLAND=1' | sudo tee -a /etc/environment
source /etc/environment

####
#firefox pwa extension runtime
####

# Install required packages for third-party repositories
sudo apt update
sudo apt install curl gpg apt-transport-https -y

# Import GPG key and enable the repository
curl -fsSL https://packagecloud.io/filips/FirefoxPWA/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/firefoxpwa-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/firefoxpwa-keyring.gpg] https://packagecloud.io/filips/FirefoxPWA/any any main" | sudo tee /etc/apt/sources.list.d/firefoxpwa.list > /dev/null

# Refresh repositories and install the package
sudo apt update
sudo apt install firefoxpwa -y

####
#brave install
####
sudo apt install curl

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install brave-browser

####
#appimagelauncher (or use https://github.com/mijorus/gearlever, or official yet unreleased appimaged)
####

sudo apt install software-properties-common -y
sudo add-apt-repository ppa:appimagelauncher-team/stable -y
sudo apt update
sudo apt install appimagelauncher -y

# config

echo "
[AppImageLauncher]
%23%20enable_daemon=true
ask_to_move=true
destination=/home/user1/AppImages
" | tee -a ~/.config/appimagelauncher.cfg

####
#appimage apps
####

# open video downloader
cd ~/Downloads || exit 1
curl -s https://api.github.com/repos/jely2002/youtube-dl-gui/releases/latest \
| grep "browser_download_url.*Open-Video.*.AppImage" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
ail-cli integrate Open-Video*.AppImage
chmod +x ~/AppImages/Open-Video*.AppImage
open ~/AppImages/Open-Video*.AppImage # needed manual launch to create desktop shortcut

####
#reinstall pre-installed apps for normal versions
####
sudo apt purge --autoremove -y firefox thunderbird
sudo snap install firefox thunderbird

####
#installation of dotnet
####

#https://github.com/dotnet/core/issues/7699
#https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#register-the-microsoft-package-repository

#error after switching from ubuntu source to microsoft online
#https://stackoverflow.com/questions/73753672/a-fatal-error-occurred-the-folder-usr-share-dotnet-host-fxr-does-not-exist

#!!! may not work
#official packages from ubuntu
sudo apt-get update && sudo apt-get install -y dotnet7 dotnet6

#microsoft distributed packages conflicts with them, so if switching origin:

declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)
# repo_version="22.04" # set manually if ubuntu-based distro
wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

#prevent conflicts
sudo apt purge "dotnet*" "aspnetcore*" "netstandard*" --autoremove -y
echo '
Package: dotnet* aspnet* netstandard*
Pin: origin "ru.archive.ubuntu.com", "security.ubuntu.com"
Pin-Priority: -10

Package: dotnet* aspnet* netstandard*
Pin: origin "packages.microsoft.com"
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/dotnet-microsoft-source
sudo apt update

#install
sudo apt install dotnet-sdk-6.0 dotnet-sdk-7.0 dotnet-sdk-8.0 -y


####
#install ungoogled-chromium
####
echo 'deb http://download.opensuse.org/repositories/home:/ungoogled_chromium/Ubuntu_Jammy/ /' | sudo tee /etc/apt/sources.list.d/home:ungoogled_chromium.list
curl -fsSL https://download.opensuse.org/repositories/home:ungoogled_chromium/Ubuntu_Jammy/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_ungoogled_chromium.gpg > /dev/null
sudo apt update
sudo apt install ungoogled-chromium -y

####
#install onlyoffice
####

#add keys
mkdir -p -m 700 ~/.gnupg
gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg

#add repos
echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee /etc/apt/sources.list.d/onlyoffice.list

sudo apt-get update
sudo apt-get install onlyoffice-desktopeditors -y

####
#github desktop
####

wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" > /etc/apt/sources.list.d/shiftkey-packages.list'

sudo apt update && sudo apt install github-desktop -y

#fedora

sudo rpm --import https://rpm.packages.shiftkey.dev/gpg.key
sudo sh -c 'echo -e "[shiftkey-packages]\nname=GitHub Desktop\nbaseurl=https://rpm.packages.shiftkey.dev/rpm/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://rpm.packages.shiftkey.dev/gpg.key" > /etc/yum.repos.d/shiftkey-packages.repo'

sudo dnf install github-desktop

####
#github cli
####

type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

####
#git authenticate
####

# interactive authentication
gh auth login

# setup credentials
gh auth setup-git

# set ~/.gitconfig
user=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /user | jq -r .login)
email=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /user/emails | jq -r ".[0].email")
echo "Setting $user <$email> as the default Git user..."
git config --global user.name "$user"
git config --global user.email "$email"

# powershell version:
'
$user = (gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /user | ConvertFrom-Json).login
$email = ((gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /user/emails | ConvertFrom-Json)[1].email)
Write-Host "Setting $user <$email> as the default Git user..."
git config --global user.name $user
git config --global user.email $email
'

####
#git set line endings
####

git config --global core.autocrlf input

####
#steam scaling
####

echo "STEAM_FORCE_DESKTOPUI_SCALING='2'" | sudo tee -a /etc/environment
#logout

####
#linux gaming
####

#https://dtf.ru/flood/1110882-igraem-na-linukse-ubuntu-lutris-wine-ge-custom-proton

sudo add-apt-repository ppa:lutris-team/lutris -y
sudo apt update
sudo apt -y install lutris

cd Downloads
curl -s https://api.github.com/repos/GloriousEggroll/wine-ge-custom/releases/latest \
| grep "browser_download_url.*tar.xz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

tar -xvf wine-lutris-GE-Proton*-x86_64.tar.xz
mkdir -p ~/.local/share/lutris/runners/wine
mv lutris-GE-Proton*-x86_64 ~/.local/share/lutris/runners/wine/

#gamemode
sudo apt install gamemode -y

#mangohud (build from source for compatibility with goverlay)
git clone https://github.com/flightlessmango/MangoHud
cd MangoHud 
./build.sh build
./build.sh install

#goverlay (apt version is outdated, needed to build)
#!!! ensure `QT_QPA_PLATFORM=wayland` set in /etc/environment

sudo apt install -y libqt5pas1 libqt5pas-dev lcl qtwayland5 #dependencies
sudo make install

####
#gnome + qt
####

sudo add-apt-repository ppa:ubuntuhandbook1/qgnomeplatform -y

sudo apt-get install -y sudo apt install qt5-gtk-platformtheme qt6-gtk-platformtheme adwaita-qt qgnomeplatform-qt5

ENV_FILE='/etc/environment'
LINE1='QT_QPA_PLATFORM=wayland'
LINE2='QT_QPA_PLATFORMTHEME=gnome'
grep -qF -- "$LINE1" "$ENV_FILE" || echo "$LINE1" | sudo tee -a "$ENV_FILE"
grep -qF -- "$LINE2" "$ENV_FILE" || echo "$LINE2" | sudo tee -a "$ENV_FILE"


####
#mitmproxy
####

#install 8.1.1.1-2 (unstable) from ubuntu repos online

####
#waydroid (android vm)
####

sudo apt install curl ca-certificates -y
curl https://repo.waydro.id | sudo bash
sudo apt install waydroid -y

####
#waydroid settings GUI
####

sudo apt install gir1.2-vte-2.91 gir1.2-webkit2-4.0 -y
wget -O - https://raw.githubusercontent.com/axel358/Waydroid-Settings/main/install.sh | bash

####
#mono
####

sudo apt install ca-certificates gnupg
sudo gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update
sudo apt install mono-devel -y

####
#broot
####

echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ stable main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
sudo apt update && sudo apt install -y broot

####
#vscodium
####
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update && sudo apt install codium

# launch args
cp /usr/share/applications/codium.desktop ~/.local/share/applications/codium.desktop
sed -i '/Exec=/s/$/ --profile vscode-settings-profile --enable-features=UseOzonePlatform --ozone-platform=wayland/' ~/.local/share/applications/codium.desktop

####
#copilot for codium
####

https://github.com/VSCodium/vscodium/discussions/1487
https://github.com/VSCodium/vscodium/issues/1546#issuecomment-1840142391 #copilot chat settings
# note: extension may be incompatible, try download older version

# note: manuall install may be required

COMPATIBLE_VERSION="1.143.0"
cd ~/Downloads || exit 1
curl -o copilot-extension.gz https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/copilot/"$COMPATIBLE_VERSION"/vspackage
gunzip copilot-extension.gz
mv copilot-extension copilot-extension.vsix
codium --install-extension copilot-extension.vsix

COMPATIBLE_CHAT_VERSION="0.12.2023120701"
curl -o copilot-chat-extension.gz https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/copilot-chat/"$COMPATIBLE_CHAT_VERSION"/vspackage
gunzip copilot-chat-extension.gz
mv copilot-chat-extension copilot-chat-extension.vsix
codium --install-extension copilot-chat-extension.vsix

CONFIG_PATH="/usr/share/codium/resources/app/product.json" # may be /opt/vscodium-bin/resources/app/product.json
CONFIG_LINE1='"GitHub.copilot": [	"inlineCompletionsAdditions", "interactive", "interactiveUserActions", "terminalDataWriteEvent"	],'
CONFIG_LINE2='"GitHub.copilot-nightly": ["inlineCompletionsAdditions", "interactive", "interactiveUserActions",	"terminalDataWriteEvent" ],'
CONFIG_LINE3='"GitHub.copilot-chat": [ "handleIssueUri", "interactive", "interactiveUserActions", "terminalDataWriteEvent", "terminalExecuteCommandEvent", "terminalSelection", "terminalQuickFixProvider", "chatProvider", "chatVariables", "chatAgents2", "chatAgents2Additions", "defaultChatAgent", "readonlyMessage", "mappedEditsProvider", "aiRelatedInformation", "codeActionAI", "findTextInFiles", "textSearchProvider", "scmInputBoxValueProvider", "contribSourceControlInputBoxMenu" ],'
CONFIG_LINE4='"trustedExtensionAuthAccess": [ "vscode.git", "vscode.github", "github.remotehub", "github.vscode-pull-request-github", "github.codespaces", "github.copilot", "github.copilot-chat" ],'
CONFIG_LINE5='"trustedExtensionProtocolHandlers": [ "vscode.git", "vscode.github-authentication" ],'

# be sure to call only once or check result !!!
sudo cp "$CONFIG_PATH" "$CONFIG_PATH".bak

sudo sed -i "/\"GitHub.copilot\"/c\    $CONFIG_LINE1" "$CONFIG_PATH"
sudo sed -i "/\"GitHub.copilot-nightly\"/c\    $CONFIG_LINE2" "$CONFIG_PATH"
sudo sed -i "/\"GitHub.copilot-chat\"/c\    $CONFIG_LINE3" "$CONFIG_PATH"

sudo sed -i "/commit/i \ \ $CONFIG_LINE4" "$CONFIG_PATH"
sudo sed -i "/commit/i \ \ $CONFIG_LINE5" "$CONFIG_PATH"

####
#disable ipv6
####

# temp
echo 1 | sudo tee /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 | sudo tee /proc/sys/net/ipv6/conf/default/disable_ipv6

# permanent
sudo tee /etc/sysctl.d/98-disable-ipv6.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

####
#latest yt-dlp
####

sudo add-apt-repository ppa:tomtomtom/yt-dlp -y # Add ppa repo to apt
sudo apt update                                 # Update package list
sudo apt install yt-dlp -y                      # Install yt-dlp

####
#firefoxpwa system
####

# Install required packages for third-party repositories
sudo apt update
#sudo apt install debian-archive-keyring # Debian-only
sudo apt install curl gpg apt-transport-https -y

# Import GPG key and enable the repository
curl -fsSL https://packagecloud.io/filips/FirefoxPWA/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/firefoxpwa-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/firefoxpwa-keyring.gpg] https://packagecloud.io/filips/FirefoxPWA/any any main" | sudo tee /etc/apt/sources.list.d/firefoxpwa.list > /dev/null

# Refresh repositories and install the package
sudo apt update
sudo apt install firefoxpwa -y

####
#flatpak
####

sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

####
#nekoray
####

curl -s https://api.github.com/repos/MatsuriDayo/nekoray/releases/latest \
| grep "browser_download_url.*x64.deb" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
sudo dpkg -i nekoray*.deb

####
#enhanced bluetooth
####

LINE="Experimental = true"
FILE="/etc/bluetooth/main.conf"
PATTERN='\[General\]'
grep -qF -- "$LINE" "$FILE" || sudo sed -i "/${PATTERN}/a${LINE}" "$FILE"
sudo systemctl restart bluetooth
sudo rfkill unblock bluetooth
sudo systemctl restart bluetooth

####
#PlasmaConfManager (idk will it work)
####

# https://store.kde.org/p/1298955/
wget -O ocs-url.deb https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1467909105/ocs-url_3.1.0-0ubuntu1_amd64.deb\?response-content-disposition\=attachment%3B%2520ocs-url_3.1.0-0ubuntu1_amd64.deb\&X-Amz-Content-Sha256\=UNSIGNED-PAYLOAD\&X-Amz-Algorithm\=AWS4-HMAC-SHA256\&X-Amz-Credential\=RWJAQUNCHT7V2NCLZ2AL%2F20231115%2Fus-east-1%2Fs3%2Faws4_request\&X-Amz-Date\=20231115T060912Z\&X-Amz-SignedHeaders\=host\&X-Amz-Expires\=3600\&X-Amz-Signature\=9e427bdfbec922b3ce5b5c83041881ff99c8b090ff567bba727ef33e59d5d650
sudo dpkg -i ocs-url.deb
rm ocs-url.deb
ocs-url ocs://install?url=https%3A%2F%2Ffiles04.pling.com%2Fapi%2Ffiles%2Fdownload%2Fj%2FeyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjE2NDQ2NjEyMjYiLCJ1IjpudWxsLCJsdCI6Imluc3RhbGwiLCJzIjoiMmRiMDFiOTMxYTViOWE5YzhiMzk1YjZlMzY4NWRiNzg2YzAyM2FjNWU5ZjA2OGYwMmIxYjFjYmFkMmE3MTczMjIzM2M0MWQ2ZjY0YThhNDM0NmEyOGE5OGIyMTUzYjA4OWI1YjRjNDZiY2JhODBiNzNkMDhiYzM1ZTQ3MTJjNzAiLCJ0IjoxNzAwMDI5NTE5LCJzdGZwIjpudWxsLCJzdGlwIjpudWxsfQ.hOjXU6dD_ZEpVwj11J2WqTNoUQpocH_bwffC7A8Zodg%2Fcom.pajuelo.plasmaConfSaver-1.6.tar.gz&type=plasma5_plasmoids&filename=com.pajuelo.plasmaConfSaver-1.6.tar.gz

####
#swap
####

# delete default swap on separate partition
sudo swapoff /dev/dm-1
sudo umount /dev/dm-1 # ??
sudo lvremove /dev/dm-1 # ??
sudo rm /dev/dm-1

# delete default swap in /
sudo swapoff /swapfile
sudo rm /swapfile

# create new and enable
sudo dd if=/dev/zero of=/swapfile count=32 bs=GiB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo sed -i '/vgkubuntu-swap/d' /etc/fstab
sudo sed -i '/swapfile/d' /etc/fstab
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo swapon /swapfile

# check
lsblk
swapon --show

####
# trash-cli
####

sudo apt install trash-cli -y
# trash-put file
