# vim: set ft=just :
# This file can be modified downstream to add custom just commands
# ## Standardized verbs
# configure- = configure something that is pre-installed on the image
# install-   = install something, no uninstall or configuration provided
# setup-     = install something and also provide configuration and/or uninstallation options
# toggle-    = turn something on/off, logic can be automatic or manual selection
# fix-       = apply fix/patch/workaround for something
# foo        = no verb is used for shortcuts or something deemed important enough to use a super memorable name

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

install-distrobox-steam:
    #!/usr/bin/env bash
    distrobox-create --unshare-netns --image ghcr.io/ublue-os/bazzite-arch --name bazzite-arch -Y
    distrobox-enter -n bazzite-arch -- bash -c 'distrobox-export --app steam'
    distrobox-enter -n bazzite-arch -- bash -c 'sudo pacman -S --noconfirm mangohud gamescope'

setup-gamescope-steam:
    #!/usr/bin/env bash
    xhost +si:localuser:$USER
    sudo chown -f -R $USER:$USER /tmp/.X11-unix

setup-root-fedora-distrobox:
    #!/usr/bin/env bash
    distrobox-create fedora -i fedora:latest --root

update-all:
    #!/usr/bin/env bash
    brew update && brew upgrade
    flatpak update -y
    distrobox-upgrade --all
    rpm-ostree upgrade
