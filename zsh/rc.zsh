autoload -U compinit && compinit

setopt autocd
setopt correctall
setopt extendedglob

export GPG_TTY=`tty`

source $HOME/.zsh/hint/init.zsh
