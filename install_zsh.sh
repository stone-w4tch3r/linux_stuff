#!/bin/bash

#use on target ubuntu (non-interactive?)

sudo apt update
sudo apt install -y git-core zsh fzf zsh-syntax-highlighting zsh-autosuggestions thefuck || exit 1
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh -s "$(which zsh)" "$USER"

sed -i 's|plugins=.*|plugins=(git dotnet adb ag ansible chucknorris colored-man-pages colorize command-not-found docker docker-compose emoji emoji-clock extract gh gitignore hitchhiker multipass npm  pip safe-paste sudo ubuntu ufw zsh-interactive-cd)|g' ~/.zshrc
echo 'zic_case_insensitive=true' | sudo tee -a /etc/environment #case-insensitive interactive cd

wget -P \
    ~/fonts_for_zsh https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf \
    ~/fonts_for_zsh https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf \
    ~/fonts_for_zsh https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf \
    ~/fonts_for_zsh https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
sudo mv ~/fonts_for_zsh/* /usr/local/share/fonts
rm -rfd ~/fonts_for_zsh

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
sed -i 's|ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|g' ~/.zshrc
echo "
# To customize prompt, run "p10k configure" or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
" \
    >> ~/.zshrc
cp configs/p10k.zsh ~/.p10k.zsh

echo "
alias gitignore=gi
alias cat=ccat
alias less=cless
alias codium='NODE_OPTIONS='' codium --enable-features=UseOzonePlatform --ozone-platform=wayland'
alias git_cp='echo -n "commit message: " && read -r message && echo \$message | git add . && git commit -m \$message && git push'
eval \$(thefuck -a)
# FOR SYNTAX-HIGHLIGHTING TO WORK, THIS LINE MUST LAST
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
" \
    >> ~/.zshrc

