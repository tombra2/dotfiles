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

# Legt Fenster "$2" in Session "$1" an, falls es fehlt, und startet darin "$3" --
# aber nur, wenn dort gerade bloss eine Shell laeuft (sonst wuerde ein laufendes
# nvim/opencode den Befehl als Tastendruck abbekommen).
_tmux_ensure_window() {
  local session="$1" name="$2" cmd="$3"
  if ! tmux list-windows -t "$session:" -F '#W' 2>/dev/null | grep -qx "$name"; then
      tmux new-window -dt "$session:" -c "$PWD" -n "$name"
  fi
  [[ -z "$cmd" ]] && return
  case "$(tmux display-message -p -t "$session:$name" '#{pane_current_command}')" in
      bash | sh | zsh | fish) tmux send-keys -t "$session:$name" "$cmd" C-m ;;
  esac
}

# Baut das nvim/opencode/terminal-Fenster-Layout in einer bereits existierenden
# Session auf. Wird von n() und vom tmux-sessionizer-Hook (~/.tmux-sessionizer) genutzt.
# Idempotent: ergaenzt nur, was fehlt -- laeuft also auch in einer Session, die
# der Sessionizer (Ctrl-F) schon ohne Layout angelegt hat.
_tmux_dev_layout() {
  local session="$1"
  _tmux_ensure_window "$session" nvim 'nvim -c Neotree'
  _tmux_ensure_window "$session" opencode 'opencode'
  _tmux_ensure_window "$session" terminal ''
  tmux select-window -t "$session:nvim"
}

n() {
  local session
  session=$(basename "$PWD" | tr . _)
  # -t= / =$session erzwingen exakte Namen; ohne das matcht tmux auch Prefixe,
  # d.h. "brandner" wuerde eine Session "brandner-frontend" treffen.
  if ! tmux has-session -t="$session" 2>/dev/null; then
      tmux new-session -ds "$session" -c "$PWD" -n nvim
  fi
  _tmux_dev_layout "$session"
  if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "=$session"
  else
      tmux attach-session -t "=$session"
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
