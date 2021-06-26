# Add preexec, but override __bp_adjust_histcontrol to preserve histcontrol.
source ~/.fig/shell/bash-preexec.sh
function __bp_adjust_histcontrol() { :; }

FIG_LAST_PS1="$PS1"
FIG_LAST_PS2="$PS2"
FIG_LAST_PS3="$PS3"

# Construct Operating System Command.
function fig_osc { printf "\033]697;"; printf $@; printf "\007"; }

function __fig_preexec() {
  __fig_ret_value="$?"

  fig bg:exec $$ $(tty) & disown

  fig_osc PreExec

  # Reset user prompts before executing a command, but only if it hasn't
  # changed since we last set it.
  if [[ -n "${FIG_USER_PS1+x}" && "${PS1}" = "${FIG_LAST_PS1}" ]]; then
    FIG_LAST_PS1="${FIG_USER_PS1}"
    export PS1="${FIG_USER_PS1}"
  fi
  if [[ -n "${FIG_USER_PS2+x}" && "${PS2}" = "${FIG_LAST_PS2}" ]]; then
    FIG_LAST_PS2="${FIG_USER_PS2}"
    export PS2="${FIG_USER_PS2}"
  fi
  if [[ -n "${FIG_USER_PS3+x}" && "${PS3}" = "${FIG_LAST_PS3}" ]]; then
    FIG_LAST_PS3="${FIG_USER_PS3}"
    export PS3="${FIG_USER_PS3}"
  fi

  _fig_done_preexec="yes"
  __bp_set_ret_value "${__fig_ret_value}" "${__bp_last_argument_prev_command}"
}

function __fig_prompt () {
  __fig_ret_value="$?"

  fig bg:prompt $$ $TTY & disown

  # Work around bug in CentOS 7.2 where preexec doesn't run if you press ^C
  # while entering a command.
  [[ -z "${_fig_done_preexec:-}" ]] && __fig_preexec ""
  _fig_done_preexec=""

  # If FIG_USER_PSx is undefined or PSx changed by user, update FIG_USER_PSx.
  if [[ -z "${FIG_USER_PS1+x}" || "${PS1}" != "${FIG_LAST_PS1}" ]]; then
    export FIG_USER_PS1="${PS1}"
  fi
  if [[ -z "${FIG_USER_PS2+x}" || "${PS2}" != "${FIG_LAST_PS2}" ]]; then
    export FIG_USER_PS2="${PS2}"
  fi
  if [[ -z "${FIG_USER_PS3+x}" || "${PS3}" != "${FIG_LAST_PS3}" ]]; then
    export FIG_USER_PS3="${PS3}"
  fi

  fig_osc "Dir=%s" "${PWD}"
  fig_osc "Shell=bash"
  START_PROMPT="\[$(fig_osc StartPrompt)\]"
  END_PROMPT="\[$(fig_osc EndPrompt)\]"
  NEW_CMD="\[$(fig_osc NewCmd)\]"

  # Reset $? first in case it's used in $FIG_USER_PSx.
  __bp_set_ret_value "${__fig_ret_value}" "${__bp_last_argument_prev_command}"
  export PS1="${START_PROMPT}${FIG_USER_PS1}${END_PROMPT}${NEW_CMD}"
  export PS2="${START_PROMPT}${FIG_USER_PS2}${END_PROMPT}"
  export PS3="${START_PROMPT}${FIG_USER_PS3}${END_PROMPT}${NEW_CMD}"

  export FIG_LAST_PS1="${PS1}"
  export FIG_LAST_PS2="${PS2}"
  export FIG_LAST_PS3="${PS3}"
}

# trap DEBUG -> preexec -> command -> PROMPT_COMMAND -> prompt shown.
preexec_functions+=(__fig_preexec)
precmd_functions+=(__fig_prompt)
