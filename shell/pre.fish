contains $HOME/.fig/bin $fish_user_paths
or set -Ua fish_user_paths $HOME/.fig/bin

if [ -d /Applications/Fig.app -o -d ~/Applications/Fig.app ] \
  && command -v fig 1>/dev/null 2>/dev/null \
  && [ -t 1 ]

  if [ -z "$FIG_PRE_ENV_VAR" ] || [ -n "$TMUX" ]
    # Generated automatically by iTerm and Terminal But needs to be
    # explicitly set for VSCode and Hyper. This variable is inherited when
    # new ttys are created using tmux and must be explictly overwritten.
    if [ -z "$TERM_SESSION_ID" ] || [ -n "$TMUX" ]
      export TERM_SESSION_ID=(uuidgen)
    end
    export FIG_INTEGRATION_VERSION=3
    export FIG_PRE_ENV_VAR=1
  end

  if command -v fig_pty 1>/dev/null 2>/dev/null
    if [ -z "$FIG_TERM" ] || [ -z "$FIG_TERM_TMUX" -a -n "$TMUX" ]
      set FIG_SHELL (~/.fig/bin/fig_get_shell)
      exec -a "figterm" ~/.fig/bin/fig_pty $FIG_SHELL
    end
  end
end

