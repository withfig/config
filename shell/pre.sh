#!/usr/bin/env bash

pathadd() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

pathadd ~/.fig/bin

if ([[ -d /Applications/Fig.app || -d ~/Applications/Fig.app ]]) \
  && [[ "${TERMINAL_EMULATOR}" != JetBrains-JediTerm ]] \
  && command -v fig 2>&1 1>/dev/null \
  && [[ -t 1 ]]; then

  # Generated automatically by iTerm and Terminal, but needs to be
  # explicitly set for VSCode and Hyper. This variable is inherited when
  # new ttys are created using Tmux of VSCode and must be explictly
  # overwritten.
  if [[ -z "${TERM_SESSION_ID}" || -n "${TMUX}" || "${TERM_PROGRAM}" = vscode ]]; then
    export TERM_SESSION_ID="$(uuidgen)"
  fi
  export FIG_INTEGRATION_VERSION=4

  # Only launch figterm if current session is not already inside PTY and command exists
  if [[ -z "${FIG_PTY}" ]] && command -v ~/.fig/bin/figterm 2>&1 1>/dev/null; then
    if [[ -z "${FIG_TERM}" || (-z "${FIG_TERM_TMUX}" && -n "${TMUX}") ]]; then
      # Pty module sets FIG_TERM or FIG_TERM_TMUX to avoid running twice. 
      FIG_SHELL=$(~/.fig/bin/fig_get_shell)
      FIG_IS_LOGIN_SHELL=0

      if ([[ -n "$BASH" ]] && shopt -q login_shell) \
        || ([[ -n "$ZSH_NAME" && -o login ]]); then
        FIG_IS_LOGIN_SHELL=1
      fi
      FIG_TERM_NAME="${FIG_SHELL} (figterm)"
      FIG_SHELL_PATH="${HOME}/.fig/bin/$(basename "${FIG_SHELL}") (figterm)"
      cp ~/.fig/bin/figterm "${FIG_SHELL_PATH}"
      FIG_SHELL="${FIG_SHELL}" FIG_IS_LOGIN_SHELL="${FIG_IS_LOGIN_SHELL}" exec -a "${FIG_TERM_NAME}" "${FIG_SHELL_PATH}"
    fi
  fi
fi
