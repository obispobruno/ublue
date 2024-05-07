# vim: set ft=make :
# This file can be modified downstream to add custom just commands
# ## Standardized verbs
# configure- = configure something that is pre-installed on the image
# install-   = install something, no uninstall or configuration provided
# setup-     = install something and also provide configuration and/or uninstallation options
# toggle-    = turn something on/off, logic can be automatic or manual selection
# fix-       = apply fix/patch/workaround for something
# foo        = no verb is used for shortcuts or something deemed important enough to use a super memorable name

setup-personal-config:
    #!/usr/bin/env bash

    git clone https://github.com/obispobruno/nvim-config.git ~/.config/nvim
    
    git clone --bare https://github.com/obispobruno/.dotfiles.git ~/.dotfiles
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
    
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/plugins/zsh-syntax-highlighting/
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ~/.config/zsh/plugins/zsh-autocomplete

install-jetbrains-font:
    #!/usr/bin/env bash
    mkdir -p ~/.local/share/fonts
    wget -P ~/.local/share/fonts $(curl -sL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep -o 'https://github.com/ryanoasis/nerd-fonts/releases/download/[^"]*' | grep JetBrainsMono.tar.xz)
    tar -xf ~/.local/share/fonts/JetBrainsMono.tar.xz -C ~/.local/share/fonts

configure-corectrl:
    #!/usr/bin/env bash
    
    mkdir -p ~/.config/autostart
    
    if [[ -f /usr/share/applications/org.corectrl.corectrl.desktop ]]; then
    	cp /usr/share/applications/org.corectrl.corectrl.desktop ~/.config/autostart/org.corectrl.CoreCtrl.desktop
    elif [[ -f /usr/share/applications/org.corectrl.CoreCtrl.desktop ]]; then
    	cp /usr/share/applications/org.corectrl.CoreCtrl.desktop ~/.config/autostart/org.corectrl.CoreCtrl.desktop
    fi
    
    rpm-ostree kargs --append-if-missing=amdgpu.ppfeaturemask=0xffffffff

configure-docker-group:
    #!/usr/bin/env bash
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker

install-brew-packages:
    #!/usr/bin/env bash
    
    brew install git
    brew install vim
    brew install ncdu
    brew install rust
    brew install tmux
    brew install htop
    brew install wget
    brew install curl
    brew install gcc
    brew install neovim
    brew install npm
    brew install binutils
    brew install ripgrep
    brew install fd
    brew install fzf
    brew install bat
    brew install eza
    brew install fastfetch
    brew install p7zip
    brew install procs
    brew install btop
    brew install syncthing
    brew install zoxide
    brew install gh
    brew install lf
    brew install unzip
    brew install unar
    brew install trash-cli
    brew install tldr
    brew install ghc
    brew install haskell-language-server
    brew install yazi
    brew install starship
    brew install dotnet
    brew install python
    brew install pipx

install-auto-cpufreq:
    #!/usr/bin/env bash
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git /tmp/auto-cpufreq
    sudo /tmp/auto-cpufreq/auto-cpufreq-installer