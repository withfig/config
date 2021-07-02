#!/usr/bin/env bash

pathadd() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

pathadd ~/.fig/bin

if ([[ -d /Applications/Fig.app || -d ~/Applications/Fig.app ]]) \
  && [[ "${TERMINAL_EMULATOR}" != JetBrains-JediTerm ]] \
  && command -v fig 1> /dev/null 2> /dev/null \
  && [[ -t 1 ]]; then

  if [[ -z "${FIG_PRE_ENV_VAR}" || -n "${TMUX}" || "${TERM_PROGRAM}" = vscode ]]; then
    # Generated automatically by iTerm and Terminal, but needs to be
    # explicitly set for VSCode and Hyper. This variable is inherited when
    # new ttys are created using Tmux of VSCode and must be explictly
    # overwritten.
    if ([[ -z "${TERM_SESSION_ID}" || -n "${TMUX}" || "${TERM_PROGRAM}" = vscode ]]); then 
      export TERM_SESSION_ID="$(uuidgen)"
    fi
    export FIG_INTEGRATION_VERSION=4
    export FIG_PRE_ENV_VAR=1
  fi

  # Only launch figterm if current session is not already inside PTY and command exists
  if [[ -z "${FIG_PTY}" ]] &&command -v ~/.fig/bin/figterm 1> /dev/null 2> /dev/null; then
    if [[ -z "${FIG_TERM}" || (-z "${FIG_TERM_TMUX}" && -n "${TMUX}") ]]; then
      # Pty module sets FIG_TERM or FIG_TERM_TMUX to avoid running twice. 
      FIG_SHELL=$(~/.fig/bin/fig_get_shell)
      FIG_TERM_NAME="${FIG_SHELL} (figterm)"
      FIG_SHELL_PATH="${HOME}/.fig/bin/$(basename "${FIG_SHELL}") (figterm)"
      cp ~/.fig/bin/figterm "${FIG_SHELL_PATH}"
      FIG_SHELL="${FIG_SHELL}" exec -a "${FIG_TERM_NAME}" "${FIG_SHELL_PATH}"
    fi
  fi
fi
