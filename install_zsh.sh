#!/bin/bash

#use on target ubuntu (non-interactive?)

sudo apt install -y git-core zsh fzf zsh-syntax-highlighting zsh-autosuggestions
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

chsh -s "$(which zsh)"
sudo chsh -s "$(which zsh)"

sed -i 's|plugins=.*|plugins=(git dotnet adb ag ansible battery cake chucknorris colored-man-pages colorize command-not-found docker docker-compose emoji emoji-clock extract gh gitignore hitchhiker multipass npm  pip safe-paste sudo ubuntu ufw zsh-interactive-cd)|g' ~/.zshrc
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
cp configs/p10k.zsh ~/.p10k.zsh

echo 'alias gitignore=gi' | tee -a ~/.zshrc
echo 'alias cat=ccat' | tee -a ~/.zshrc
echo 'alias less=cless' | tee -a ~/.zshrc
echo "alias git_cp='echo -n "commit message: " && read -r message && echo \$message | git add . && git commit -m \$message && git push'" \
    | tee -a ~/.zshrc
