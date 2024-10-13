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

go() {
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
  if [ -n $p1 ] && [ -d $p1 ] ; then
    echo $p1
    if [ -d "$HOME/.software" ] ; then
      folder=$(ls $HOME/.software/ | grep "Godot" | fzf)
      exe=$HOME/.software/$folder/$(ls $HOME/.software/$folder | fzf)
      if file $exe | grep "ELF" ; then
        $exe -e $p1/project.godot
        exit 0
      fi
    else
      echo "No Godot versions found in $HOME/.software"
      exit 1
    fi
  fi
  if [ -d "$HOME/.software" ] ; then
    folder=$(ls $HOME/.software/ | grep "Godot" | fzf)
    exe=$HOME/.software/$folder/$(ls $HOME/.software/$folder | fzf)
    if file $exe | grep "ELF" ; then
      $exe
    fi
  else
    echo "No Godot versions found in $HOME/.software"
  fi
}

# Open tmux window with zk recent
tzk() {
    if [[ -z $TMUX ]]; then
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
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}
