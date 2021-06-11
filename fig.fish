contains $HOME/.fig/bin $fish_user_paths
or set -Ua fish_user_paths $HOME/.fig/bin

if [ -d /Applications/Fig.app -o -d ~/Applications/Fig.app ] \
  && command -v fig 1>/dev/null 2>/dev/null

  if [ -t 1 ] && [ -z "$FIG_ENV_VAR" ] || [ -n "$TMUX" ]
    # Gives fig context for cwd in each window.
    fig bg:init $fish_pid (tty)

    # Run aliases shell script
    if [ -s ~/.fig/user/aliases/_myaliases.sh ]
      bash ~/.fig/user/aliases/*.sh
    end

    # Check for prompts or onboarding.
    if [ -s ~/.fig/tools/prompts.sh ]
      bash ~/.fig/tools/prompts.sh
    end

    # Generated automatically by iTerm and Terminal But needs to be
    # explicitly set for VSCode and Hyper. This variable is inherited when
    # new ttys are created using tmux and must be explictly overwritten.
    if [ -z "$TERM_SESSION_ID" ] || [ -n "$TMUX" ]
      export TERM_SESSION_ID=(uuidgen)
    end
    export TTY=(tty)
    export FIG_INTEGRATION_VERSION=3
    export FIG_ENV_VAR=1
  end

  # We use a shell variable to make sure this doesn't load twice
  # https://fishshell.com/docs/current/cmds/if.html.
  if [ -z "$FIG_SHELL_VAR" ]
    function fig_keybuffer --on-signal SIGUSR1
      echo fig bg:fish-keybuffer "$TERM_SESSION_ID" $FIG_INTEGRATION_VERSION 0 (commandline -C) \"(commandline)\" \
        | base64 \
        | /usr/bin/nc -U /tmp/fig.socket
    end

    function fig_precmd --on-event fish_prompt
      fig bg:prompt $fish_pid (tty) &; disown
    end

    function fig_preexec --on-event fish_preexec
      fig bg:exec $fish_pid (tty) &; disown
    end

    set FIG_SHELL_VAR 1

    # Prevents wierd interaction where setting the title with ANSI escape
    # sequence triggers prompt redraw.
    fig settings autocomplete.addStatusToTerminalTitle false &
    fig bg:exec $fish_pid (tty) &
  end
end
