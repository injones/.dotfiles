#!/bin/bash

# Simple bootstrap script for Arch WSL / lightweight installs

download_file() {
    local url=$1
    local dest=$2
    echo "Downloading file from $url to $dest"
    curl -sSL $url -o $dest
    return $?
}

checksum() {
    local file=$1
    local expected=$2
    local actual=$(sha256sum $file)
    if [ "$expected" = "$actual" ]; then
        return 0
    fi
    return 1
}

contains_ignore_case() {
    local value="${1,,}"  # bash lowercase ????
    shift
    for element in "$@"; do
        if [[ "${element,,}" == "$value" ]]; then
            return 0
        fi
    done
    return 1
}

install_go() {
    echo "
        --------------------------------------
        ---------------- GO ------------------
        --------------------------------------
    "
    go_tar=/tmp/go.tar.gz
    go_dest=/usr/local
    go_version=1.25.1
    if [ -d "$go_dest/go" ]; then
        sudo rm -rf "$go_dest/go"
    fi
    download_file https://go.dev/dl/go$go_version.linux-amd64.tar.gz $go_tar
    sudo tar -C $go_dest -xzvf $go_tar
}

# .local/bin
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p $HOME/.local/bin
fi

# .local/scripts
if [ ! -d "$HOME/.local/scripts" ]; then
    mkdir -p $HOME/.local/scripts
fi

sudo sed -i '/^#en_GB.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sudo locale-gen
echo 'LANG=en_GB.UTF-8' | sudo tee /etc/locale.conf
echo 'KEYMAP=uk' | sudo tee /etc/vconsole.conf
export LANG=en_GB.UTF-8

sudo pacman -Syu

# apt packages
sudo pacman --noconfirm -S \
    unzip \
    base-devel \
    xsel \
    stow \
    tmux \
    curl \
    p7zip \
    jq \
    xclip \
    imagemagick \
    wget \
    file \
    git \
    man-db \
    nvm \
    zoxide \
    fd \
    ripgrep \
    fzf \
    neovim \
    zk \
    dotnet-sdk \
    aspnet-runtime \
    docker

sudo systemctl enable docker.service
sudo usermod -aG docker $USER
[ ! $(command -v go) ] && install_go
