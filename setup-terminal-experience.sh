#!/bin/bash
# Install WezTerm
yay -S wezterm zsh-autosuggestions eza zoxide thefuck ripgrep fzf fd bat tldr zoxide yazi ffmpegthumbnailer ffmpeg sevenzip jq poppler imagemagick --noconfirm

# Clone fzf-git for better support with git
git clone https://github.com/junegunn/fzf-git.sh.git
# Install theme for bat
mkdir -p "$(bat --config-dir)/themes"
curl --create-dirs --output-dir "$(bat --config-dir)/themes" -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build

# Install nerd fonts
# Create shared fonts dir
mkdir -p ~/.local/share/fonts
curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf --output ~/.local/share/fonts/MesloLGSNF-Regular.ttf
curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf --output ~/.local/share/fonts/MesloLGSNF-Bold.ttf
curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf --output ~/.local/share/fonts/MesloLGSNF-Italic.ttf
curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20BoldItalic.ttf --output ~/.local/share/fonts/MesloLGSNF-BoldItalic.ttf

# get dotfiles
git clone git@github.com:ViktorSheverdin/dotfiles.git
cd dotfiles
stow .

# Install plugins
yay -S --noconfirm zsh-autosuggestions zsh-syntax-highlighting

# Symlink into Oh My Zsh
ln -sf /usr/share/zsh/plugins/zsh-autosuggestions ${ZSH:-$HOME/.oh-my-zsh}/custom/plugins/zsh-autosuggestions
ln -sf /usr/share/zsh/plugins/zsh-syntax-highlighting ${ZSH:-$HOME/.oh-my-zsh}/custom/plugins/zsh-syntax-highlighting

# Homebrew
# brew install powerlevel10k
# echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc

# Arh
yay -S --noconfirm zsh-theme-powerlevel10k-git
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.tmux.conf

