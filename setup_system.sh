####
#init
####
sudo apt update && sudo apt upgrade -y && sudo apt install neofetch -y
sudo apt install git curl network-manager-openvpn -y
sudo apt install -y vlc
sudo apt purge --autoremove -y libreoffice*
sudo apt purge --autoremove -y ktorrent kmines ksudoku kmahjongg
sudo snap install rider webstorm datagrip bitwarden

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
sudo tee -a /etc/modprobe.d/hid_apple.conf <<EOF
#options hid_apple swap_fn_leftctrl=1
#options hid_apple swap_opt_cmd=1
#options hid_apple fnmode=2
options hid_apple iso_layout=0
options hid_apple fnmode=2
options hid_apple swap_fn_leftctrl=1
options hid_apple swap_opt_cmd=1
options hid_apple rightalt_as_rightctrl=1
#options hid_apple ejectcd_as_delete=1
EOF

#for remapping eject to delete, 'Input Remapper' can be used

#apply config
sudo update-initramfs -u
sudo modprobe -r hid_apple; sudo modprobe hid_apple

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
#brave install
####
sudo apt install curl

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install brave-browser

####
#reinstall pre-installed apps for normal versions
####
sudo apt purge --autoremove -y firefox thunderbird
sudo snap install firefox thunderbird

####
#installation of dotnet
####

#https://github.com/dotnet/core/issues/7699

####
#install ungoogled-chromium
####
echo 'deb http://download.opensuse.org/repositories/home:/ungoogled_chromium/Ubuntu_Lunar/ /' | sudo tee /etc/apt/sources.list.d/home:ungoogled_chromium.list
curl -fsSL https://download.opensuse.org/repositories/home:ungoogled_chromium/Ubuntu_Lunar/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_ungoogled_chromium.gpg > /dev/null
sudo apt update
sudo apt install ungoogled-chromium

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
echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee -a /etc/apt/sources.list.d/onlyoffice.list

sudo apt-get update
sudo apt-get install onlyoffice-desktopeditors -y

####
#github desktop
####

wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" > /etc/apt/sources.list.d/shiftkey-packages.list'

sudo apt update && sudo apt install github-desktop -y

####
#github cli
####

type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y