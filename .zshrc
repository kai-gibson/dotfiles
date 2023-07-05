# Enable colors and change prompt:
autoload -U colors && colors

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

setopt PROMPT_SUBST
# Old
#PROMPT="%F{10}%n%f@%m %{%F{blue}%}%1~%{%F{green}%}$(parse_git_branch)%{%F{none}%} %F{10}~%f> "
PROMPT="%F{10}%n%f@%m %{%F{blue}%}%1~%{%F{green}%}$(parse_git_branch)%{%F{none}%} ~> "

# Custom Variables
EDITOR=nvim
BROWSER=brave

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zshhistory
setopt appendhistory
setopt NO_BEEP

## Basic auto/tab complete:
#autoload -U compinit zstyle ':completion:*'  matcher-list 'm:{a-z}={A-Z}'
#zmodload zsh/complist
#compinit
#_comp_options+=(globdots)               # Include hidden files.
#
## Custom ZSH Binds
#bindkey '^ ' autosuggest-accept

# Emacs keybindings
bindkey -e

# Load plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null
source /home/kai/.config/scripts/lfcd.sh
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
#source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null

# Custom functions
# lfcd () {
#     tmp="$(mktemp)"
#     # `command` is needed in case `lfcd` is aliased to `lf`
#     command lfub -last-dir-path="$tmp" "$@"
#     if [ -f "$tmp" ]; then
#         dir="$(cat "$tmp")"
#         rm -f "$tmp"
#         if [ -d "$dir" ]; then
#             if [ "$dir" != "$(pwd)" ]; then
#                 cd "$dir"
#             fi
#         fi
#     fi
# }

# Aliases
alias ls="ls -hN --color=auto --group-directories-first"
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias vim="nvim"
alias rmm="/usr/bin/env rm"
alias rm="trash"
alias cp="cp"
alias mv="mv"
alias mkdir="mkdir"
alias hardrm="bleachbit --shred"
alias screenSwap="sh /home/kai/.config/scripts/screenSwap.sh"
alias hibernate="systemctl hibernate"
alias pac="paru"
alias vx="vim ~/.local/share/pac/pkgList"
alias sys="sudo systemctl"
#alias bright="xrandr --output eDP-1 --brightness"
alias lf=lfcd
alias weather="curl wttr.in"
alias config='/usr/bin/env git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazyconfig="lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias calc="noglob calc"
# This could be optimised, might replace cbatticon with it
alias batt="upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | grep -o -E '[^ ]*%'"

# Path
export PATH=$PATH:~/.local/bin

# Autostart custom tmux session on launch
sh /home/kai/.config/scripts/tmuxStart.sh

# Set default editor
export EDITOR='nvim'

# This is the list for lf icons:
export LF_ICONS="di=:\
fi=:\
tw=:\
ow=:\
ln=:\
or=❌:\
ex=:⌖\
*.txt=:\
*.mom=:\
*.me=:\
*.ms=:\
*.png=:\
*.webp=:\
*.ico=:\
*.jpg=:\
*.jpe=:\
*.jpeg=:\
*.gif=:\
*.svg=:\
*.tif=:\
*.tiff=:\
*.xcf=🖌:\
*.html=󰇧:\
*.xml=:\
*.gpg=🔒:\
*.css=:\
*.pdf=:\
*.djvu=:\
*.epub=:\
*.csv=:\
*.xlsx=:\
*.tex=:\
*.md=:\
*.r=:\
*.R=:\
*.rmd=:\
*.Rmd=:\
*.m=:\
*.mp3=🎵:\
*.opus=🎵:\
*.ogg=🎵:\
*.m4a=🎵:\
*.flac=🎵:\
*.wav=🎵:\
*.mkv=󰎁:\
*.mp4=🎵:\
*.webm=󰎁:\
*.mpeg=󰎁:\
*.avi=󰎁:\
*.mov=󰎁:\
*.mpg=󰎁:\
*.wmv=󰎁:\
*.m4b=󰎁:\
*.flv=󰎁:\
*.zip=:\
*.rar=:\
*.7z=:\
*.tar.gz=:\
*.1=ℹ:\
*.nfo=ℹ:\
*.info=ℹ:\
*.log=:\
*.iso=󰗮:\
*.img=󰗮:\
*.bib=:\
*.ged=:\
*.part=󰋔:\
*.torrent=󰍇:\
*.jar=♨:\
*.java=♨:\
"

# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**'
zstyle :compinstall filename '/home/kai/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
