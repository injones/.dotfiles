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
