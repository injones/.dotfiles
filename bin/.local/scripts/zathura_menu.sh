#!/bin/bash

OPTS='--info=inline --print-query --bind=ctrl-space:print-query,tab:replace-query'
BOOK_DIR=$HOME/Books
BOOK=$(cd $BOOK_DIR ; find *.pdf -type f | fzf $OPTS --color=fg:#d0d0d0,fg+:#d0d0d0,bg:#121212,bg+:#262626 --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00 --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf --color=border:#262626,label:#aeaeae,query:#d9d9d9 --border="bold" --border-label="" --preview-window="border-bold" --prompt="> " --marker=">" --pointer="◆" --separator="─" --scrollbar="│" | tail -1)
if [ -n "$BOOK" ]; then
    exec i3-msg -q "exec --no-startup-id zathura $BOOK_DIR/$BOOK"
fi
