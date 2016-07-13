#===============================================================================
#
# ~/.zshrc
# Written by Minoru (eual.jp@gmail.com)
#
# zsh 4.3.17 (x86_64-unknown-linux-gnu)
#
#===============================================================================



#-------------------------------------------------------------------------------
#
# HISTORY
#

# History file
HISTFILE=~/.zhistory
# The number of lines the shell will keep within one session
HISTSIZE=10240
# The number of lines of history will be saved
SAVEHIST=8192
# All running zsh sessions will have exactly the same history
# Don't worry - '!' command and so will work only with current session's history
setopt SHARE_HISTORY
# Remove all duplicates of current command from history, add current to end
setopt HIST_IGNORE_ALL_DUPS
# Don't save any commands beginning with space
setopt HIST_IGNORE_SPACE
# Don't save 'history' and 'fc' commands
setopt HIST_NO_STORE
# Enable extended globs to interpret things like rm ^(file|file2)
setopt EXTENDED_GLOB
# split parameters into words after substitution
# E.g.:
# D="one two three"
# With this option on (bash and dash behave like that):
# ./x $D   # argv == ["x", "one", "two", "three"]
# Without this option (the default):
# ./x $D   # argv == ["x", "one two three"]
# See https://bnw.im/p/EEIAKW (Russian!) for details on this
setopt SH_WORD_SPLIT



#-------------------------------------------------------------------------------
#
# PROMPT
#

# Load and initialize colors - we will use it soon
autoload colors && colors
# Prompt on the left is % if regular user or # if root
PROMPT="%{$fg[green]%}%# %{$reset_color%}"
# if connected via ssh, make prompt red
[[ -n ${SSH_CONNECTION} ]] && PROMPT="%{$fg[red]%}$HOST%# %{$reset_color%}"
# Prompt on the right is current directory (green font)
RPROMPT="%{$fg[green]%}%~%{$reset_color%}"



#-------------------------------------------------------------------------------
#
# ALIASES
#
# NOTE: if you don't want an alias to be used (for example, you went just 'du',
# but alias is 'du -h') you have three options:
# - use full path to binaries (continuing example above, it will look like 
#   '/bin/du')
# - use 'noglob' before command name (e.g., 'noglob du')
# - use backslash before command name (e.g., '\du')

# Regular aliases
alias ls="ls -F --color"
alias l="ls"
alias ll="ls -l"
alias la="ls -a"
alias sl="ls"
alias e="vim"
alias ta="tmux attach -t"
alias ncal="ncal -M" # weeks start at Monday
alias free="free -m"
alias grep="grep --colour"
alias bzip2='bzip2 -vv --best'
alias bunzip2='bunzip2 -vv'
alias gzip='gzip --best -v'
alias gunzip='gunzip -v'
alias less='less --RAW-CONTROL-CHARS --quit-if-one-screen --no-init'
alias netstat='netstat --numeric --program'
alias pqiv='pqiv -f -i -n'
alias mutt='PATH="/usr/lib/mutt:$PATH" mutt'
# Some nocorrect aliases (needed only if CORRECT is set)
alias df='nocorrect df -h'
alias du='nocorrect du -sh'
alias mv='nocorrect mv -i'
alias cp='nocorrect cp -i'
alias rm='nocorrect rm -i'
alias vim='nocorrect vim'
alias mc='nocorrect mc'
alias mkdir='nocorrect mkdir -p'
# You need run-help module to be loaded to have 'run-help' command
# See MISCELLANEOUS section below
alias help="run-help"

# Some more complicated but still useful aliases
alias rtorrent='tmux a -t "=rtorrent" || tmux new -s rtorrent "echo \"\033]0;rtorrent\a\" && rtorrent" \; set status off'
alias mcabber='tmux a -t "=mcabber" || tmux new -s mcabber "echo \"\033]0;mcabber\a\" && mcabber" \; set status off'
alias irssi='tmux a -t "=irssi" || tmux new -s irssi "stty start \"\" stop \"\" && echo \"\033]0;irssi\a\" && irssi" \; set status off'
alias ocaml='rlwrap ocaml'
alias newsbeuter='tmux a -t "=news" || tmux new -s news "echo \"\033]0;news\a\" && torify newsbeuter 2>/dev/null" \; set status off'
alias find_original='git annex find | xargs -I "{}" -- find -L ~/torrents/downloads -samefile {}'

if [ "$TERM" = "linux" ]; then
    alias mplayer='mplayer -vo fbdev2'
    alias startx='rm -f ~/.xsession-errors; setsid startx; while [ "`jobs | wc -l`" -ne "0" ]; do fg ; done; exit'
fi

# Suffix aliases for easier files processing
# PDF
alias -s pdf=zathura

# FB 2.1
alias -s fb2=fbless
alias -s fb2.bz2=fbless

# DejaVu
alias -s djvu=zathura
alias -s djv=zathura

# Global aliases
alias -g L="| less"
alias -g H="| head"
alias -g T="| tail"
alias -g G="| grep"



#-------------------------------------------------------------------------------
#
# FUNCTIONS
#

# This code will change terminal emulator's title
# As far as this action makes sense only in X terminal (and screen, but I don't
# use it), case used for checking are we in X terminal or where
# NOTE: if we're in the tty, $TERM will be "linux"
[[ -n "${SSH_CONNECTION}" ]] && titleHost="[$HOST] "
case $TERM in
    xterm* | rxvt* | screen*)
        
        # Precmd is called just before the prompt is printed
        precmd() {
            title="${titleHost}"
            if [ -n "$TMUX" ]; then
                title="${title}(`tmux display-message -p '#S'`) "
            fi
            title="${title}zsh"
            print -Pn "\033]0;${title}\a"
        }
        
        # Preexec is called just before any command line is executed
        # $1 is the command being executad
        # sed used to cut off parameters of command
        preexec() {
            title="${titleHost}"
            if [ -n "$TMUX" ]; then
                title="${title}(`tmux display-message -p '#S'`) "
            fi
            title="${title}`echo $1 | head -n1 | sed -r 's/^((sudo |torify )?[^[:space:]]+).*/\1/'`"
            print -Pn "\033]0;${title}\a"
        }

        # There are postexec too, but I don't need it as far as I configured precmd
        ;;
esac


function mcd() {
    # Create directory and cd to it
    mkdir -p "$1" && cd "$1"
}


function lcd() {
    # cd to directory and do ls
    cd "$1" && ls
}


#
# GTD STUFF
#
# Copied from this series of posts:
# - http://cs-syd.eu/posts/2015-06-14-gtd-with-taskwarrior-part-1-intro.html
# - http://cs-syd.eu/posts/2015-06-21-gtd-with-taskwarrior-part-2-collection.html
# - http://cs-syd.eu/posts/2015-06-28-gtd-with-taskwarrior-part-3-tickling.html
# - http://cs-syd.eu/posts/2015-07-05-gtd-with-taskwarrior-part-4-processing.html
# - http://cs-syd.eu/posts/2015-07-12-gtd-with-taskwarrior-part-5-doing.html

alias in='task add +in'
alias ti='task in'
alias tw='task w'
alias sd='vim /home/minoru/docs/gtd/someday.markdown'
alias t=task
setopt promptsubst
export PROMPT='%{$fg[yellow]%}$(task +in +PENDING count) '$PROMPT

__tickle () {
    deadline=$1
    shift
    task add +in +tickle wait:$deadline $@
}
alias tickle=__tickle

alias think='tickle tomorrow'

#-------------------------------------------------------------------------------
#
# MISCELLANEOUS
#

# Don't beep even if zsh don't like something
setopt NO_BEEP
# Change directory even if user forgot to put 'cd' command in front, but entered
# path is valid
setopt AUTO_CD
# If possible, correct commands
setopt CORRECT
# Use colors in auto-completion
eval `dircolors`
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# Making things like "{1-3}" and "{a-d}" working (it expands to "1 2 3" and "a b
# c d")
setopt BRACECCL
# Send CONT signal automatically when disowning jobs
setopt AUTO_CONTINUE
# All files created by zsh (it happens when you use redirection of command's
# output to non-existent file) will have ug+rwX,o-rwx (or 750 for directories
# and 640 for files) perrmissions
umask 0027
# Load help system, which can show parts of man pages where specified command
# described. Also, add help="run-help" alias (see above in ALIASES section)
autoload run-help
# key bindings
# exporting EDITOR=vim makes ZSH switch into Vi mode; I don't like that
bindkey -e
# needed when connected by ssh, don't hurt if you're connected locally
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
#bindkey "\e[2~" quoted-insert
bindkey "\e[5C" forward-word
bindkey "\e[5D" backward-word
bindkey "\e\e[C" forward-word
# for urxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line


#-------------------------------------------------------------------------------
#
# COMPLETION
#

# case-insensitive,partial-word and then substring completion
# http://hintsforums.macworld.com/archive/index.php/t-6493.html
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' #'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# Sets autocompletion
autoload -Uz compinit && compinit

# stack autocompletion as per
# https://github.com/commercialhaskell/stack/wiki/Shell-autocompletion#for-zsh-users
autoload -Uz bashcompinit && bashcompinit
eval "$($HOME/.local/bin/stack --bash-completion-script "$HOME/.local/bin/stack")"

#-------------------------------------------------------------------------------
#
# LOCAL SETTINGS
#

if [ -n "$HOST" -a -f "$HOME/.zshrc.$HOST" ]; then
    source "$HOME/.zshrc.$HOST"
fi
