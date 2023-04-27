#!/bin/bash

export ZSH=$HOME/.oh-my-zsh

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="pygmalion"

plugins=(git mvn python zsh-z zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
