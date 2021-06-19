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

    export TTY=(tty)
    export FIG_ENV_VAR=1
  end

  if [ -z "$FIG_SHELL_VAR" ]
    # Prevents weird interaction where setting the title with ANSI escape
    # sequence triggers prompt redraw.
    fig settings autocomplete.addStatusToTerminalTitle false &
    fig bg:exec $fish_pid (tty) &

    source ~/.fig/shell/post.fish
  end
end
