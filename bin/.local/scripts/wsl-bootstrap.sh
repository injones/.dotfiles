#!/bin/bash

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
    if [ -d "$go_dest/go" ]; then
        sudo rm -rf "$go_dest/go"
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
    wget https://packages.microsoft.com/config/debian/$debian_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
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
    NVIM_VERSION=0.11.4
    NVIM_DEST=/opt/nvim-linux-x86_64
    NVIM_TMP_DEST=/tmp/nvim.tar.gz
    download_file "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/nvim-linux-x86_64.tar.gz" $NVIM_TMP_DEST
    sudo rm -rf $NVIM_DEST
    sudo mkdir -p $NVIM_DEST
    sudo chmod a+rX $NVIM_DEST
    sudo tar -C /opt -xzf $NVIM_TMP_DEST
    sudo ln -sf $NVIM_DEST/bin/nvim /usr/local/bin/
}

install_zk() {
    echo "
        -----------------------------------------
        ---------------- ZK ---------------------
        -----------------------------------------
    "
    ZK_VERSION=0.15.1
    ZK_TMP=/tmp/zk.tar.gz
    ZK_BIN=/usr/local/bin/zk
    download_file "https://github.com/zk-org/zk/releases/download/v0.15.1/zk-v0.15.1-linux-amd64.tar.gz" $ZK_TMP
    sudo rm -rf $ZK_BIN
    sudo tar -C /usr/local/bin -xvf $ZK_TMP
}

install_docker() {
    echo "
        ---------------------------------------------
        ---------------- Docker ---------------------
        ---------------------------------------------
    "
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo usermod -aG docker $USER
}

install_kubectl() {
    echo "
        ----------------------------------------------
        ---------------- kubectl ---------------------
        ----------------------------------------------
    "
    KUBECTL_VER=1.34.0
    curl -L https://dl.k8s.io/release/v$KUBECTL_VER/bin/linux/amd64/kubectl -o $HOME/.local/bin/kubectl
    curl -LO https://dl.k8s.io/release/v$KUBECTL_VER/bin/linux/amd64/kubectl.sha256
    echo "$(cat kubectl.sha256)  $HOME/.local/bin/kubectl" | sha256sum --check
    if [ "$?" -eq 0 ]; then
        chmod +x $HOME/.local/bin/kubectl
    fi
}

install_pwsh() {
    echo "
        ----------------------------------------------
        ---------------- pwsh ------------------------
        ----------------------------------------------
    "
    # Temporary because https://github.com/PowerShell/PowerShell/issues/25865
    if [ -z $(apt list --installed | grep 'packages-microsoft-prod') ]; then
        sudo apt install powershell
        return 0
    fi
    pwsh_version="7.5.3"
    curl -L "https://github.com/PowerShell/PowerShell/releases/download/v$pwsh_version/powershell_$pwsh_version-1.deb_amd64.deb" -o pwsh.deb
    if command -v iconv >/dev/null; then
        curl -LO https://github.com/PowerShell/PowerShell/releases/download/v$pwsh_version/hashes.sha256
        checksum=$(iconv -f UTF-16 -t UTF-8 hashes.sha256 | awk '/deb/ { print $1 }')
        if ! echo "$checksum  pwsh.deb" | sha256sum --check >/dev/null 2>&1; then
            rm pwsh.deb
            return 1
        fi
    fi
    sudo dpkg -i -y pwsh.deb
    sudo apt-get install -f
    rm pwsh.deb
}

install_helm() {
    echo "
        ----------------------------------------------
        ---------------- helm ------------------------
        ----------------------------------------------
    "
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
}

install_minikube() {
    echo "
        --------------------------------------------------
        ---------------- minikube ------------------------
        --------------------------------------------------
    "
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb
    rm minikube_latest_amd64.deb
}

# .local/bin
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p $HOME/.local/bin
fi

# .local/scripts
if [ ! -d "$HOME/.local/scripts" ]; then
    mkdir -p $HOME/.local/scripts
fi

sudo apt-get update
sudo apt-get upgrade -y

# apt packages
sudo apt install -y \
    gpg \
    apt-transport-https \
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
    file \
    git \
    man-db \
    starship

declare -a SELECTED=("nvm" "go" "zoxide" "fd" "rg" "fzf" "yazi" "dotnet" "az" "nvim" "zk" "docker" "kubectl" "pwsh" "helm" "minikube")
FORCE=1
debian_version=$(cat /etc/os-release | sed -n -e 's/VERSION_ID="\([0-9][0-9]*\)\"/\1/p')

while getopts "fi:" opt; do
    case $opt in
        f ) FORCE=0                  ;;
        i ) SELECTED_ARG="$OPTARG"   ;;
    esac
done
shift $(( $OPTIND - 1 ))

if [ -n "$SELECTED_ARG" ]; then
    IFS=',' read -r -a SELECTED <<< "$SELECTED_ARG"
fi

if [[ $FORCE -eq 0 ]]; then
    echo "Installing (forced):"
else
    echo "Installing:"
fi

printf "%s\n" "${SELECTED[@]}"

# node
if contains_ignore_case "nvm" "${SELECTED[@]}" && { ! command -v node >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_node
fi

# go
if contains_ignore_case "go" "${SELECTED[@]}" && { ! command -v go >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_go
fi

# zoxide
if contains_ignore_case "zoxide" "${SELECTED[@]}" && { ! command -v zoxide >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# fd
if contains_ignore_case "fd" "${SELECTED[@]}" && { ! command -v fd >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_fd
fi

# ripgrep
if contains_ignore_case "rg" "${SELECTED[@]}" && { ! command -v rg >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_ripgrep
fi

# fzf
if contains_ignore_case "fzf" "${SELECTED[@]}" && { ! command -v fzf >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_fzf
fi

# yazi
if contains_ignore_case "yazi" "${SELECTED[@]}" && { ! command -v yazi >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_yazi
fi

# dotnet
if contains_ignore_case "dotnet" "${SELECTED[@]}" && { ! command -v dotnet >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_dotnet
fi

# az
if contains_ignore_case "az" "${SELECTED[@]}" && { ! command -v az >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# nvim
if contains_ignore_case "nvim" "${SELECTED[@]}" && { ! command -v nvim >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_nvim
fi

# zk
if contains_ignore_case "zk" "${SELECTED[@]}" && { ! command -v zk >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_zk
fi

# docker
if contains_ignore_case "docker" "${SELECTED[@]}" && { ! command -v docker >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_docker
fi

# kubectl
if contains_ignore_case "kubectl" "${SELECTED[@]}" && { ! command -v kubectl >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_kubectl
fi

# pwsh
if contains_ignore_case "pwsh" "${SELECTED[@]}" && { ! command -v pwsh >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_pwsh
fi

# helm
if contains_ignore_case "helm" "${SELECTED[@]}" && { ! command -v helm >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_helm
fi

# minikube
if contains_ignore_case "minikube" "${SELECTED[@]}" && { ! command -v minikube >/dev/null || [[ $FORCE -eq 0 ]]; }; then
    install_minikube
fi
