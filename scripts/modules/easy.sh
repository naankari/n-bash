#!/bin/bash


_neasyLoad() {
    # Setting color
    ##########################################
    export CLICOLOR=1
    export LSCOLORS=ExFxBxDxCxegedabagacad
    alias ls="ls -Fh"

    # Setting history parameters
    ##########################################
    export HISTCONTROL=ignorespace,erasedups
    export HISTSIZE=10000
    export HISTFILESIZE=20000
    shopt -s histappend

    # Other
    ##########################################
    alias sudo="sudo "

    export EDITOR=vim
}

_neasyLoad
