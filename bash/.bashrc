export PATH="/home/thomas/.local/share/mise/installs/node/latest/bin:$PATH"
export PATH="/home/thomas/.local/share/mise/installs/node/26.1.0/bin:$PATH"
# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

alias c='clear'
alias reload='source ~/.bashrc'
alias upn='~/.config/script/upn'
alias db-reset='~/.config/script/db-reset'
alias install-cq-configs='~/dev/defaults/install-cq-configs.sh'
alias install-symfony='bash ~/dev/defaults/install-symfony.sh'
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

herdr_sessionizer() {
    "$HOME/.config/script/herdr-sessionizer"
}
bind -x '"\C-f":"herdr_sessionizer"'

n() {
  if [[ $# -gt 0 ]]; then
    nvim "$@"
  else
    "$HOME/.config/script/herdr-sessionizer" "$PWD"
  fi
}

export PATH=/home/thomas/.opencode/bin:$PATH
export PATH="$HOME/.config/script:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

. "$HOME/.local/share/../bin/env"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/.local/opt/go/bin
export PATH=$PATH:$HOME/.local/opt/go/bin

export PATH="$HOME/.config/composer/vendor/bin:$PATH"
