#!/usr/bin/env bash

devel() {
    echo -n "> "
    read cmd
    path=$1
    if [[ -z $path ]]; then
        path="."
    fi
    podman run \
        --rm \
        -v "$path":/usr/src/app \
        -w /usr/src/app \
        --cap-add=SYS_PTRACE \
        --security-opt seccomp=unconfined \
        -it \
        my-gcc-app \
        $cmd
}

go-container() {
    echo -n "> "
    read cmd
    path=$1
    if [[ -z $path ]]; then
        path="."
    fi
    podman run \
        --rm \
        -v "$path":/usr/src/app \
        -w /usr/src/app \
        -v "$HOME"/.go:/usr/src/go \
        -e GOPATH=/usr/src/go \
        -p 8080:8080 \
        --cap-add=SYS_PTRACE \
        --security-opt seccomp=unconfined \
        -it \
        golang:1.21 \
        $cmd
}

# launch godot
godot() {
    p1="$1" # folder with godot project
    if [ -n $p1 ] && [ -d $p1 ]; then
        echo $p1
        if [ -d "$HOME/.software" ]; then
            folder=$(ls $HOME/.software/ | grep "Godot" | fzf)
            exe=$HOME/.software/$folder/$(ls $HOME/.software/$folder | fzf)
            if file $exe | grep "ELF"; then
                $exe -e $p1/project.godot
                exit 0
            fi
        else
            echo "No Godot versions found in $HOME/.software"
            exit 1
        fi
    fi
    if [ -d "$HOME/.software" ]; then
        folder=$(ls $HOME/.software/ | grep "Godot" | fzf)
        exe=$HOME/.software/$folder/$(ls $HOME/.software/$folder | fzf)
        if file $exe | grep "ELF"; then
            $exe
        fi
    else
        echo "No Godot versions found in $HOME/.software"
    fi
}

# Open tmux window with zk recent
tzk() {
    if [[ -z "$TMUX" ]]; then
        echo "Not in a tmux session!"
        return 1
    fi
    local session
    session=$(tmux list-sessions -F "#{session_name}" -f "#{session_attached}")
    tmux new-window -n "zk" -c "$ZK_NOTEBOOK_DIR"
    tmux split-window -v -p 80
    tmux swap-pane -t 1 -U
    tmux clock-mode -t 0
    tmux send-keys -t 1 "zk recent" Enter
    tmux select-window -t "$session:zk"
    tmux select-pane -t 1
}

# Fuzzy select from common directories
ccd() {
    if [ -n "$COMMON_DIRS" ]; then
        selected=$(echo $COMMON_DIRS | sed "s/,/\n/g" | fzf)
        cd "$selected"
    else
        echo "COMMON_DIRS env not set."
    fi
}

# tm - create new tmux session, or switch to existing one. Works from within tmux too. (@bag-man)
# `tm` will allow you to select your tmux session via fzf.
# `tm irc` will attach to the irc session (if it exists), else it will create it.

tm() {
    [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
    if [ $1 ]; then
        tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1")
        return
    fi
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) && tmux $change -t "$session" || echo "No sessions found."
    return 1
}

background_job() {
    nohup "$@" >/dev/null 2>&1 &
}

rmf() {
    ls | fzf -m | xargs -I {} rm {}
}

zathls() {
    cd $HOME/Books
    find *.pdf -type f | fzf --bind 'enter:become(nohup zathura {} > /dev/null 2>&1 &)'
}

where() {
    declare -A SHORTCUTS=([code]='Microsoft.Visua' [vim]='nvim')
    local PROG=$1
    if [[ -n ${SHORTCUTS[$PROG]} ]]; then
        PROG=${SHORTCUTS[$PROG]}
    fi
    if [[ -z "$PROG" ]]; then
        PROG="nvim"
    fi
    if [[ -z $(command -v pgrep) ]]; then
        echo "pgrep not installed"
        return 1
    fi
    CURUSR=$(whoami)
    PROGIDS=$(pgrep -u $CURUSR "$PROG")
    if [[ -z ${PROGIDS[@]} ]]; then
        echo "$PROG not running"
        return 1
    fi
    declare -a PATHS
    for id in $PROGIDS; do
        PATHS+=($(readlink -e /proc/$id/cwd))
    done
    SELECTED=$(printf "%s\n" "${PATHS[@]}" | sort -u | fzf --exit-0)
    if [[ -n "$SELECTED" ]]; then
        cd "$SELECTED"
    fi
}

tzdev() {
    if [[ -z $TMUX ]]; then
        echo "Not in a tmux session!"
        return 1
    fi
    local SESSION=$(tmux list-sessions -F "#{session_name}" -f "#{session_attached}")
    tmux new-window -n "dev" -c "$HOME"
    tmux split-window -t 0 -h -p 55
    tmux split-window -v -t 0 -p 40
    tmux send-key -t 0 "btop" Enter
    tmux send-key -t 1 "cd $HOME/git ; clear" Enter
    tmux send-key -t 2 "ccd" Enter
    tmux select-window -t "dev"
    tmux select-pane -t 2
}

gitcd() {
    local GIT_DIR=$HOME/git
    local DIR=$(ls "$GIT_DIR" | fzf)
    cd "$GIT_DIR/$DIR"
}
