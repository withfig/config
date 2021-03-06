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
      export FIG_CHECKED_PROMPTS 1
    end

    export TTY=(tty)
    export FIG_ENV_VAR=1
  end

  if [ -z "$FIG_SHELL_VAR" ]
    function fig_keybuffer --on-signal SIGUSR1
      echo fig bg:fish-keybuffer "$TERM_SESSION_ID" $FIG_INTEGRATION_VERSION "$TTY" $fish_pid 0 (commandline -C) \"(commandline)\" \
        | base64 \
        | /usr/bin/nc -U /tmp/fig.socket
    end

    function fig_osc; printf "\033]697;"; printf $argv; printf "\007"; end
    function fig_copy_fn; functions -e $argv[2]; functions -c $argv[1] $argv[2]; end
    function fig_fn_defined; test (functions $argv[1] | grep -vE '^ *(#|function |end$|$)' | wc -l | xargs) != 0; end

    function fig_wrap_prompt
      set -l last_status $status
      fig_osc StartPrompt

      sh -c "exit $last_status"
      printf "%b" (string join "\n" $argv)
      fig_osc EndPrompt

      sh -c "exit $last_status"
    end

    function fig_preexec --on-event fish_preexec
      fig bg:exec $fish_pid (tty) &; disown
      fig_osc PreExec

      if fig_fn_defined fig_user_mode_prompt
        fig_copy_fn fig_user_mode_prompt fish_mode_prompt
      end

      if fig_fn_defined fig_user_right_prompt
        fig_copy_fn fig_user_right_prompt fish_right_prompt
      end

      fig_copy_fn fig_user_prompt fish_prompt

      set fig_has_set_prompt 0
    end

    function fig_precmd --on-event fish_prompt
      fig bg:prompt $fish_pid (tty) &; disown

      if [ $fig_has_set_prompt = 1 ]
        fig_preexec
      end

      fig_osc "Dir=%s" $PWD
      fig_osc "Shell=fish" $PWD
      fig_osc "PID=%d" $fish_pid
      fig_osc "TTY=%s" (tty)
      if [ -z $SSH_TTY ]
        fig_osc "SSH=0"
      else
        fig_osc "SSH=1"
      end

      if fig_fn_defined fish_mode_prompt
        fig_copy_fn fish_mode_prompt fig_user_mode_prompt
        function fish_mode_prompt; fig_wrap_prompt (fig_user_mode_prompt); end
      end

      if fig_fn_defined fish_right_prompt
        fig_copy_fn fish_right_prompt fig_user_right_prompt
        function fish_right_prompt; fig_wrap_prompt (fig_user_right_prompt); end
      end

      fig_copy_fn fish_prompt fig_user_prompt
      function fish_prompt; fig_wrap_prompt (fig_user_prompt); fig_osc NewCmd; end

      set fig_has_set_prompt 1
    end

    set FIG_SHELL_VAR 1
    set fig_has_set_prompt 0

    # Prevents weird interaction where setting the title with ANSI escape
    # sequence triggers prompt redraw.
    fig settings autocomplete.addStatusToTerminalTitle false &
    fig bg:exec $fish_pid (tty) &
  end
end
