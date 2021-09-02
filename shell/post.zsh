autoload -Uz add-zsh-hook

function fig_osc { printf "\033]697;"; printf $@; printf "\007"; }

FIG_HAS_ZSH_PTY_HOOKS=1
FIG_HAS_SET_PROMPT=0

fig_preexec() {
  fig bg:exec $$ $TTY &!

  # Restore user defined prompt before executing.
  PS1="$FIG_USER_PS1"
  PS2="$FIG_USER_PS2"
  PS3="$FIG_USER_PS3"
  RPS1="$FIG_USER_RPS1"

  FIG_HAS_SET_PROMPT=0
  fig_osc PreExec
}

fig_precmd() {
  fig bg:prompt $$ $TTY &!

  if [ $FIG_HAS_SET_PROMPT -eq 1 ]; then
    # ^C pressed while entering command, call preexec manually to clear fig prompts.
    fig_preexec
  fi

  fig_osc "Dir=%s" "$PWD"
  fig_osc "Shell=zsh"
  fig_osc "PID=%d" "$$"
  fig_osc "TTY=%s" "${TTY}"
  fig_osc "SSH=%d" "${SSH_TTY:+1:-0}"

  START_PROMPT=$(fig_osc StartPrompt)
  END_PROMPT=$(fig_osc EndPrompt)
  NEW_CMD=$(fig_osc NewCmd)

  # Save user defined prompts.
  FIG_USER_PS1="$PS1"
  FIG_USER_PS2="$PS2"
  FIG_USER_PS3="$PS3"
  FIG_USER_RPS1="$RPS1"

  PS1="%{$START_PROMPT%}$PS1%{$END_PROMPT$NEW_CMD%}"
  PS2="%{$START_PROMPT%}$PS2%{$END_PROMPT%}"
  PS3="%{$START_PROMPT%}$PS3%{$END_PROMPT$NEW_CMD%}"
  RPS1="%{$START_PROMPT%}$RPS1%{$END_PROMPT%}"
  FIG_HAS_SET_PROMPT=1

  # Temporary workaround for bug where istrip is activated (for unknown reasons).
  # When istrip is turned on, input characters are strippped to seven bits.
  # This causes zle insertion to stop due to our reliance on `fig_insert` being bound to a unicode character 
  command stty -istrip
}

add-zsh-hook precmd fig_precmd
add-zsh-hook preexec fig_preexec
