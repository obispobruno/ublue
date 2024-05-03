# vim: set ft=make :
# This file can be modified downstream to add custom just commands

setup-personal-config:
    #!/usr/bin/env bash
    git clone https://github.com/obispobruno/nvim-config.git ~/.config/nvim

    git clone https://github.com/obispobruno/BigBagKbdTrixXKB.git /tmp/BigBagKbdTrixXKB
    /tmp/BigBagKbdTrixXKB/install-dreymar-xmod.sh

    mkdir -p ~/.local/share/fonts
    wget -P ~/.local/share/fonts $(curl -sL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep -o 'https://github.com/ryanoasis/nerd-fonts/releases/download/[^"]*' | grep JetBrainsMono.zip)
    7z x ~/.local/share/fonts/JetBrainsMono.zip -o$HOME/.local/share/fonts

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/plugins/zsh-syntax-highlighting/
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ~/.config/zsh/plugins/zsh-autocomplete

configure-corectrl:
    #!/usr/bin/env bash
    
    mkdir -p ~/.config/autostart
    
    if [[ -f /usr/share/applications/org.corectrl.corectrl.desktop ]]; then
    cp /usr/share/applications/org.corectrl.corectrl.desktop ~/.config/autostart/org.corectrl.CoreCtrl.desktop
    elif [[ -f /usr/share/applications/org.corectrl.CoreCtrl.desktop ]]; then
    cp /usr/share/applications/org.corectrl.CoreCtrl.desktop ~/.config/autostart/org.corectrl.CoreCtrl.desktop
    fi
    
    rpm-ostree kargs --append-if-missing=amdgpu.ppfeaturemask=0xffffffff
