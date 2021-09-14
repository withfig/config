autoload -Uz add-zsh-hook

FIG_HOSTNAME=$(hostname -f 2> /dev/null || hostname)

if [[ -e /proc/1/cgroup ]] && grep -q docker /proc/1/cgroup; then
  FIG_IN_DOCKER=1
else
  FIG_IN_DOCKER=0
fi

__fig() {
  if [[ -d /Applications/Fig.app || -d ~/Applications/Fig.app ]] && command -v fig 2>&1 1>/dev/null; then
    fig "$@"
  fi
}

function fig_osc { printf "\033]697;"; printf $@; printf "\007"; }

FIG_HAS_ZSH_PTY_HOOKS=1
FIG_HAS_SET_PROMPT=0

fig_preexec() {
  __fig bg:exec $$ $TTY &!

  # Restore user defined prompt before executing.
  PS1="$FIG_USER_PS1"
  PS2="$FIG_USER_PS2"
  PS3="$FIG_USER_PS3"
  [[ -v RPS1 ]] && RPS1="$FIG_USER_RPS1"
  [[ -v RPROMPT ]] && RPROMPT="$FIG_USER_RPROMPT"

  FIG_HAS_SET_PROMPT=0
  fig_osc PreExec
}

fig_wrap_prompt() {
  # This function expands the prompt if necessary. If not, it sets it
  # as is.
  if [[ "${1: -1}" == '%' ]]; then
    echo "%{$START_PROMPT%}$1{$END_PROMPT%}"
  else
    echo "%{$START_PROMPT%}$1%{$END_PROMPT%}"
  fi
}

fig_precmd() {
  local LAST_STATUS=$?
  __fig bg:prompt $$ $TTY &!

  if [ $FIG_HAS_SET_PROMPT -eq 1 ]; then
    # ^C pressed while entering command, call preexec manually to clear fig prompts.
    fig_preexec
  fi

  fig_osc "Dir=%s" "$PWD"
  fig_osc "Shell=zsh"
  fig_osc "PID=%d" "$$"
  fig_osc "SessionId=%s" "${TERM_SESSION_ID}"
  fig_osc "ExitCode=%s" "${LAST_STATUS}"
  fig_osc "TTY=%s" "${TTY}"
  fig_osc "Log=%s" "${FIG_LOG_LEVEL}"

  if [[ -n "${SSH_TTY}" ]]; then
    fig_osc "SSH=1"
  else
    fig_osc "SSH=0"
  fi

  fig_osc "Docker=%d" "${FIG_IN_DOCKER}"
  fig_osc "Hostname=%s@%s" "${USER:-root}" "${FIG_HOSTNAME}"

  START_PROMPT=$(fig_osc StartPrompt)
  END_PROMPT=$(fig_osc EndPrompt)
  NEW_CMD=$(fig_osc NewCmd)

  # Save user defined prompts.
  FIG_USER_PS1="$PS1"
  FIG_USER_PS2="$PS2"
  FIG_USER_PS3="$PS3"
  FIG_USER_RPS1="$RPS1"
  FIG_USER_RPROMPT="$RPROMPT"

  PS1=$(fig_wrap_prompt $PS1)
  PS2=$(fig_wrap_prompt $PS2)
  PS3=$(fig_wrap_prompt $PS3)
  [[ -v RPS1 ]] && RPS1=$(fig_wrap_prompt $RPS1)
  [[ -v RPROMPT ]] && RPROMPT=$(fig_wrap_prompt $RPROMPT)

  FIG_HAS_SET_PROMPT=1

  # Temporary workaround for bug where istrip is activated when running brew install.
  # When istrip is turned on, input characters are strippped to seven bits.
  # This causes zle insertion to stop due to our reliance on `fig_insert` being bound to a unicode character
  [[ -t 1 ]] && command stty -istrip
}

add-zsh-hook precmd fig_precmd
add-zsh-hook preexec fig_preexec
