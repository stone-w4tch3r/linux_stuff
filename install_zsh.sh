#!/bin/bash

#use on target ubuntu (non-interactive?)

sudo apt install -y git-core zsh fzf zsh-syntax-highlighting zsh-autosuggestions
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

chsh -s $(which zsh)
sudo chsh -s $(which zsh)

sed -i 's|plugins=.*|plugins=(git dotnet adb ag ansible battery cake chucknorris colored-man-pages colorize command-not-found docker docker-compose emoji emoji-clock extract gh gitignore hitchhiker multipass npm  pip safe-paste sudo ubuntu ufw zsh-interactive-cd)|g' ~/.zshrc
echo 'alias gitignore=gi' | tee -a ~/.zshrc
echo 'alias cat=ccat' | tee -a ~/.zshrc
echo 'zic_case_insensitive=true' | sudo tee -a /etc/environment #case-insensitive interactive cd

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's|ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|g' ~/.zshrc
