export PATH="/home/thomas/.local/share/mise/installs/node/26.1.0/bin:$PATH"
# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

source ~/.local/share/omarchy/default/bash/rc

alias c='clear'
alias reload='source ~/.bashrc'
alias upn='~/.config/script/upn'
alias db-reset='~/.config/script/db-reset'
alias migra='ddev exec php bin/console make:migration'
alias docmigra='ddev exec php bin/console doctrine:migrations:migrate'

alias esp='mpremote connect /dev/ttyUSB0'

alias sql='ddev exec php bin/console dbal:run-sql'
alias start='ddev start && ddev launch && ddev mailpit'
alias stop='ddev stop'
alias lg='lazygit'
alias dtest='ddev exec php bin/phpunit'
alias mkdir='mkdir -pv'
alias rm='rm -i'
alias cp='cp -iv'
alias mv='mv -iv'

tmux_sessionizer_popup() {
    if [[ -n "$TMUX" ]]; then
        tmux display-popup -E -w 50% -h 50% "$HOME/.config/script/tmux-sessionizer"
    else
        "$HOME/.config/script/tmux-sessionizer"
    fi
}
bind -x '"\C-f":"tmux_sessionizer_popup"'

export PATH=/home/thomas/.opencode/bin:$PATH
export PATH="$HOME/.config/script:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

. "$HOME/.local/share/../bin/env"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/.local/opt/go/bin
export PATH=$PATH:$HOME/.local/opt/go/bin
