#!/bin/sh

# Simple bootstrap script for Debian WSL / lightweight installs

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

install_go() {
    echo "
        --------------------------------------
        ---------------- GO ------------------
        --------------------------------------
    "
    go_tar=/tmp/go.tar.gz
    go_dest=/usr/local
    if [ -d "$go_dest/go" ]; then
        rm -rf "$go_dest/go"
    fi
    download_file https://go.dev/dl/go1.24.1.linux-amd64.tar.gz $go_tar
    sudo tar -C $go_dest -xzvf $go_tar
}

install_node() {
    echo "
        ----------------------------------------
        ---------------- NODE ------------------
        ----------------------------------------
    "
    # nvm
    if [ ! -d "$HOME/.nvm" ]; then
        NVM_VERSION=0.40.2
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    # node
    [ $(command -v nvm) ] && nvm install node
}

install_fzf() {
    echo "
        ---------------------------------------
        ---------------- FZF ------------------
        ---------------------------------------
    "
    FZF_TAR=/tmp/fzf.tar.gz
    FZF_DEST=/usr/bin
    FZF_VERSION=0.60.3
    download_file "https://github.com/junegunn/fzf/releases/download/v$FZF_VERSION/fzf-$FZF_VERSION-linux_amd64.tar.gz" $FZF_TAR
    sudo tar -C $FZF_DEST -xzvf $FZF_TAR
}

install_ripgrep() {
    echo "
        ---------------------------------------
        ---------------- RG -------------------
        ---------------------------------------
    "
    rg_deb=/tmp/rg.deb
    RG_VERSION=14.1.0
    download_file "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep_$RG_VERSION-1_amd64.deb" $rg_deb
    sudo dpkg -i $rg_deb
}

install_fd() {
    echo "
        ---------------------------------------
        ---------------- FD -------------------
        ---------------------------------------
    "
    fd_deb=/tmp/fd.deb
    download_file https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-musl_10.2.0_amd64.deb $fd_deb
    sudo dpkg -i $fd_deb
}

install_yazi() {
    echo "
        -----------------------------------------
        ---------------- YAZI -------------------
        -----------------------------------------
    "
    YAZI_ZIP=/tmp/yazi.zip
    YAZI_DIR=/tmp/yazi
    YAZI_DEST="$HOME/.local/bin"
    YAZI_VERSION=0.4.2
    download_file "https://github.com/sxyazi/yazi/releases/download/v$YAZI_VERSION/yazi-x86_64-unknown-linux-gnu.zip" $YAZI_ZIP
    unzip -j $YAZI_ZIP "yazi-x86_64-unknown-linux-gnu/yazi" -d $YAZI_DEST
}

install_dotnet() {
    echo "
        -----------------------------------------
        ---------------- .NET -------------------
        -----------------------------------------
    "
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb

    sudo apt-get update &&
        sudo apt-get install -y dotnet-sdk-9.0 aspnetcore-runtime-9.0
}

install_nvim() {
    echo "
        -----------------------------------------
        ---------------- NVIM -------------------
        -----------------------------------------
    "
    NVIM_VERSION=0.10.4
    NVIM_DEST=/opt/nvim-linux64
    NVIM_TMP_DEST=/tmp/nvim.tar.gz
    download_file "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/nvim-linux-x86_64.tar.gz" $NVIM_TMP_DEST
    sudo rm -rf $NVIM_DEST
    sudo mkdir -p $NVIM_DEST
    sudo chmod a+rX $NVIM_DEST
    sudo tar -C /opt -xzf $NVIM_TMP_DEST
    sudo ln -sf $NVIM_DEST/bin/nvim /usr/local/bin/
}

# .local/bin
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p $HOME/.local/bin
fi

sudo apt-get update
sudo apt-get upgrade -y

# apt packages
sudo apt install -y \
    unzip \
    build-essential \
    xsel \
    stow \
    tmux \
    curl \
    p7zip-full \
    jq \
    xclip \
    imagemagick \
    poppler-utils \
    wget \
    file

# node
[ ! $(command -v node) ] && install_node

# go
[ ! $(command -v go) ] && install_go

# zoxide
[ ! $(command -v zoxide) ] && curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# fd
[ ! $(command -v fd) ] && install_fd

# ripgrep
[ ! $(command -v rg) ] && install_ripgrep

# fzf
[ ! $(command -v fzf) ] && install_fzf

# yazi
[ ! $(command -v yazi) ] && install_yazi

# dotnet
[ ! $(command -v dotnet) ] && install_dotnet

# az
[ ! $(command -v az) ] && curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# nvim
[ ! $(command -v nvim) ] && install_nvim
