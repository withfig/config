contains $HOME/.fig/bin $fish_user_paths
or set -Ua fish_user_paths $HOME/.fig/bin


if [ -d /Applications/fig.app ] || [ -d ~/Applications/fig.app ] && command -v fig 1>/dev/null 2>/dev/null

    if [ -t 1 ] && ([ -z "$FIG_ENV_VAR" ] || [ ! -z "$TMUX" ])

        # Gives fig context for cwd in each window
        fig bg:init $fish_pid (tty)

        # Run aliases shell script
        [ -s ~/.fig/user/aliases/_myaliases.sh ] && bash ~/.fig/user/aliases/*.sh

        # Check for prompts or onboarding
        [ -s ~/.fig/tools/prompts.sh ] && bash ~/.fig/tools/prompts.sh

        # Generated automatically by iTerm and Terminal
        # But needs to be explicitly set for VSCode and Hyper
        # This variable is inherited when new ttys are created using Tmux
        # and must be explictly overwritten
        if [ -z "$TERM_SESSION_ID" ] || [ ! -z "$TMUX" ]
            export TERM_SESSION_ID=(uuidgen)
        end
        export TTY=(tty)
        export FIG_ENV_VAR=1

    end


    # We use a shell variable to make sure this doesn't load twice

    # https://fishshell.com/docs/current/cmds/if.html
    if [ -z "$FIG_SHELL_VAR" ]

        function fig_precmd --on-event fish_prompt
            fig bg:prompt $fish_pid (tty) &
            disown
        end

        function fig_preexec --on-event fish_preexec
            fig bg:exec $fish_pid (tty) &
            disown
        end

        set FIG_SHELL_VAR 1

        fig bg:exec $fish_pid (tty) &
    end

end
