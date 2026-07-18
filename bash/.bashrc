export PATH="/home/thomas/.local/share/mise/installs/node/26.1.0/bin:$PATH"
# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

source ~/.local/share/omarchy/default/bash/rc

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

tmux_sessionizer_popup() {
    if [[ -n "$TMUX" ]]; then
        tmux display-popup -E -w 50% -h 50% "$HOME/.config/script/tmux-sessionizer"
    else
        "$HOME/.config/script/tmux-sessionizer"
    fi
}
bind -x '"\C-f":"tmux_sessionizer_popup"'

# Baut das nvim/opencode/terminal-Fenster-Layout in einer bereits existierenden
# Session auf. Wird von n() und vom tmux-sessionizer-Hook (~/.tmux-sessionizer) genutzt.
_tmux_dev_layout() {
  local session="$1"
  tmux send-keys -t "$session:nvim" 'nvim -c Neotree' C-m
  tmux new-window -t "$session" -c "$PWD" -n opencode
  tmux send-keys -t "$session:opencode" 'opencode' C-m
  tmux new-window -t "$session" -c "$PWD" -n terminal
  tmux select-window -t "$session:nvim"
}

n() {
  local session
  session=$(basename "$PWD" | tr . _)
  if ! tmux has-session -t "$session" 2>/dev/null; then
      tmux new-session -ds "$session" -c "$PWD" -n nvim
      _tmux_dev_layout "$session"
  fi
  if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "$session"
  else
      tmux attach-session -t "$session"
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
