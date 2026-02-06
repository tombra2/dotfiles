# ---------------------------------------------------
# Oh My Zsh Basis
# ---------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  docker
  docker-compose
  sudo
  web-search
  dirhistory
  zsh-autosuggestions
  zsh-syntax-highlighting
  copyfile
  copybuffer
)

source "$ZSH/oh-my-zsh.sh"

# ---------------------------------------------------
# Pfade
# ---------------------------------------------------
export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.config/script/:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }
zle -N n
bindkey '^b' n
# ---------------------------------------------------
# Autosuggestions mit TAB akzeptieren + Completion
# ---------------------------------------------------
# Funktion: Wenn Autosuggestion vorhanden -> accept, sonst normale Completion

# ---------------------------------------------------
# FZF
# ---------------------------------------------------
export FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# praktische FZF-Shortcuts


bindkey -s ^f "tmux-sessionizer\n"


# function sesh-sessions() {
#   {
#     # echtes TTY für fzf sicherstellen
#     exec </dev/tty
#     exec <&1
#
#     local session
#     session=$(sesh list -t -c | fzf \
#       --height 40% \
#       --reverse \
#       --border-label ' sesh ' \
#       --border \
#       --prompt '⚡  ') || return
#
#     zle reset-prompt > /dev/null 2>&1 || true
#     [[ -z "$session" ]] && return
#
#     sesh connect "$session"
#   }
# }
#
# zle -N sesh-sessions
#
# # alte ^F-Bindung entfernen (wichtig)
# bindkey -r '^F'
#
# # ^F in allen relevanten Keymaps binden
# bindkey -M emacs '^F' sesh-sessions
# bindkey -M viins '^F' sesh-sessions
# bindkey -M vicmd '^F' sesh-sessions
# bindkey -r '^K'
#
# # ^F in allen relevanten Keymaps binden
# bindkey -M emacs '^K' sesh-sessions
# bindkey -M viins '^K' sesh-sessions
# bindkey -M vicmd '^K' sesh-sessions
# ---------------------------------------------------
# Aliases
# ---------------------------------------------------
alias gs='git status --short'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gd='git diff --output-indicator-new=" " --output-indicator-old=" "'
alias lg='lazygit'

if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi
# ---------------------------------------------------
# Platform IO 
# ---------------------------------------------------

alias serial='picocom -b 9600 /dev/ttyACM0'

alias y='yazi'
alias c='clear'
alias reload_zsh='source ~/.zshrc'
alias update='sudo pacman -Syu && yay -Syu --noconfirm'
alias upn='~/.config/script/upn'
alias migra='ddev exec php bin/console make:migration'
alias docmigra='ddev exec php bin/console doctrine:migrations:migrate'

alias sql='ddev exec php bin/console dbal:run-sql'
alias start='ddev start && ddev launch && ddev mailpit'
alias stop='ddev stop'


alias mkdir='mkdir -pv'
alias rm='rm -i'
alias cp='cp -iv'
alias mv='mv -iv'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'


# -------MICROPYTHON--------------------------------

alias µ-push='ampy --port /dev/ttyUSB0 put'
alias µ-pull='ampy --port /dev/ttyUSB0 get'
alias µ-rm='ampy --port /dev/ttyUSB0 get rm'
alias µ-ls='ampy --port /dev/ttyUSB0 get ls'


# ---------------------------------------------------
# zoxide
# ---------------------------------------------------
eval "$(zoxide init --cmd cd zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/go/bin

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

. "$HOME/.local/share/../bin/env"
export PATH=$PATH:$HOME/.local/opt/go/bin
