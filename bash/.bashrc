# ==============================================================================
# Interactive shell
# ==============================================================================

[[ $- != *i* ]] && return


# ==============================================================================
# Omarchy
# ==============================================================================

if [[ -f /etc/omarchy.conf ]]; then
    source /etc/omarchy.conf
    export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
    export OMARCHY_PATH="/usr/share/omarchy"
fi

source "$OMARCHY_PATH/default/bash/rc"


# ==============================================================================
# Bash completion
# ==============================================================================

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi


# ==============================================================================
# Environment
# ==============================================================================

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

[[ -s "$HOME/.config/envman/load.sh" ]] && source "$HOME/.config/envman/load.sh"


# ==============================================================================
# PATH
# ==============================================================================

export PATH="$HOME/.local/share/mise/installs/node/latest/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.config/script:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="$HOME/.local/opt/go/bin:$PATH"


# ==============================================================================
# General aliases
# ==============================================================================

alias c='clear'
alias reload='source ~/.bashrc'
alias lg='lazygit'

alias mkdir='mkdir -pv'
alias rm='rm -i'
alias cp='cp -iv'
alias mv='mv -iv'


# ==============================================================================
# DDEV / Symfony
# ==============================================================================

alias start='ddev start && ddev launch && ddev mailpit'
alias stop='ddev stop'

alias dtest='ddev exec php bin/phpunit'

alias migra='ddev exec php bin/console make:migration'
alias docmigra='ddev exec php bin/console doctrine:migrations:migrate'
alias sql='ddev exec php bin/console dbal:run-sql'


# ==============================================================================
# Project setup
# ==============================================================================

alias install-cq-configs="$HOME/dev/defaults/install-cq-configs.sh"
alias install-symfony="bash $HOME/dev/defaults/install-symfony.sh"


# ==============================================================================
# ESP
# ==============================================================================

alias esp='mpremote connect /dev/ttyUSB0'


# ==============================================================================
# Neovim / Sessionizer
# ==============================================================================

bind -x '"\C-f":"herdr-sessionizer"'

n() {
    if (( $# > 0 )); then
        nvim "$@"
    else
        herdr-sessionizer "$PWD"
    fi
}
