# vim: set ft=just :
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
    rm -rf ~/.config
    rm -rf ~/.local/bin
    rm -rf ~/.local/share/nvim
    rm -rf ~/.bashrc
    rm -rf ~/.zshrc
    rm -rf ~/.dotfiles
    rm -rf ~/README.md
    rm -rf ~/README.org
    
    git clone https://github.com/obispobruno/nvim-config.git ~/.config/nvim
    
    git clone --bare https://github.com/obispobruno/.dotfiles.git ~/.dotfiles
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
    echo 'Checking out to desktop branch'
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout desktop
    
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

configure-group-permissions:
    #!/usr/bin/env bash
    sudo usermod -aG docker $USER
    sudo usermod -aG libvirt $USER
    sudo usermod -aG wireshark $USER

install-brew-packages:
    #!/usr/bin/env bash
    
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
    brew install dotnet@6
    brew install python
    brew install pipx
    brew install zsh-autocomplete
    brew install zsh-autosuggestions
    brew install zsh-syntax-highlighting

install-opentabletdriver:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    if grep -qvz "arch" <<< $(distrobox list); then \
      Assemble noconfirmcreate "" "arch"; \
    fi && \
    distrobox enter -n arch -- bash -c 'paru -S opentabletdriver --noconfirm' && \
    mkdir -p ~/.config/systemd/user/ && \
    rm -f ~/.config/systemd/user/arch-opentabletdriver.service && \
    wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/OpenTabletDriver/opentabletdriver.service -O ~/.config/systemd/user/arch-opentabletdriver.service && \
    systemctl --user daemon-reload && \
    systemctl enable --user --now arch-opentabletdriver.service && \
    distrobox enter -n arch -- bash -c 'distrobox-export --app otd-gui'
