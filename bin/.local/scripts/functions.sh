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

#-v $HOME/.mozilla/firefox/g0nza781.Twitch/extensions:/usr/lib/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384} \
ff() {
    if podman images --filter reference=firefox | grep -q "firefox"; then
        firefoxDir=$1
        if [[ ! -S /tmp/pulseaudio.socket ]]; then
            pactl load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket
            cat << EOF > /tmp/pulseaudio.client.conf
default-server = unix:/tmp/pulseaudio.socket
# Prevent a server running in the container
autospawn = no
daemon-binary = /bin/true
# Prevent the use of shared memory
enable-shm = false
EOF
        fi
        if [[ -z $firefoxDir ]]; then
            (podman run \
                --rm \
                -e DISPLAY \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                --env PULSE_SERVER=unix:/tmp/pulseaudio.socket \
                --env PULSE_COOKIE=/tmp/pulseaudio.cookie \
                --volume /tmp/pulseaudio.socket:/tmp/pulseaudio.socket \
                --volume /tmp/pulseaudio.client.conf:/etc/pulse/client.conf \
                -u 1000:1000 \
                --security-opt label=type:container_runtime_t \
                --memory 2048m \
                firefox) &> /dev/null & disown
        else
            $firefoxDir=$(realpath $firefoxDir)
            if [[ -e $firefoxDir ]]; then
                (podman run \
                    --rm \
                    -e DISPLAY \
                    -v /tmp/.X11-unix:/tmp/.X11-unix \
                    -v "$firefoxDir":/root/.mozilla/firefox \
                    --security-opt label=type:container_runtime_t \
                    --memory 2048m \
                    firefox) &> /dev/null & disown
            fi
        fi
    fi
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
