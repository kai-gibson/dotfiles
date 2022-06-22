if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Aliases

vim="nvim"
alias rmm=rm
alias rm=trash
alias hardrm="bleachbit --shred"
alias screenSwap="sh /home/kai/.config/scripts/screenSwap.sh"
alias hibernate="systemctl hibernate"
alias pac="paru"
alias bright="xrandr --output eDP-1 --brightness"
alias lf=lfub
alias weather="curl wttr.in"
alias config='/usr/bin/env git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Automatically start a tmux session on booting fish 
# (script has an if handler for tmux already existing and throws a silent error)

sh /home/kai/.config/scripts/tmuxStart.sh
export EDITOR='nvim'

# This is the list for lf icons:
export LF_ICONS="di=📁:\
fi=:\
tw=🤝:\
ow=📂:\
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
*.html=🌎:\
*.xml=📰:\
*.gpg=🔒:\
*.css=🎨:\
*.pdf=:\
*.djvu=:\
*.epub=:\
*.csv=:\
*.xlsx=:\
*.tex=📜:\
*.md=📜:\
*.r=📜:\
*.R=📜:\
*.rmd=📜:\
*.Rmd=📜:\
*.m=📜:\
*.mp3=🎵:\
*.opus=🎵:\
*.ogg=🎵:\
*.m4a=🎵:\
*.flac=🎵:\
*.wav=🎵:\
*.mkv=:\
*.mp4=🎵:\
*.webm=:\
*.mpeg=:\
*.avi=:\
*.mov=:\
*.mpg=:\
*.wmv=:\
*.m4b=:\
*.flv=:\
*.zip=📦:\
*.rar=📦:\
*.7z=📦:\
*.tar.gz=📦:\
*.1=ℹ:\
*.nfo=ℹ:\
*.info=ℹ:\
*.log=📙:\
*.iso=📀:\
*.img=📀:\
*.bib=🎓:\
*.ged=👪:\
*.part=💔:\
*.torrent=🔽:\
*.jar=♨:\
*.java=♨:\
"

