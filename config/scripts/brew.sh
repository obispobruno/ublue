#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

just install-brew

brew install \
  git \
  vim \
  ncdu \
  rust \
  tmux \
  htop \
  wget \
  curl \
  gcc \
  neovim \
  ripgrep \
  fd \
  bat \
  fzf \
  eza \
  p7zip \
  gh \
  lf \
  yazi \
  unar \
  trash-cli \
  tldr \
  ghc \
  haskell-language-server
