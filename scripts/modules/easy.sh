#!/bin/bash



# Setting color
##########################################
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls="ls -GFh"

# Setting history parameters
##########################################
export HISTCONTROL=ignorespace,erasedups
export HISTSIZE=10000
shopt -s histappend

# Other
##########################################
alias sudo="sudo "

export EDITOR=vim
