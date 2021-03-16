#!/usr/bin/env bash

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathadd ~/.fig/bin

if ([[ -d /Applications/fig.app ]] || [[ -d ~/Applications/fig.app ]]) && [ ! "$TERMINAL_EMULATOR" = JetBrains-JediTerm ]  && command -v fig 1> /dev/null 2> /dev/null
then
    if  [[ -t 1 ]] && ([[ -z "$FIG_ENV_VAR" ]] || [[ ! -z "$TMUX" ]])
    then

        # Run aliases shell script
        [ -s ~/.fig/user/aliases/_myaliases.sh ] && source ~/.fig/user/aliases/*.sh

        # Generated automatically by iTerm and Terminal
        # But needs to be explicitly set for VSCode and Hyper
        # This variable is inherited when new ttys are created using Tmux
        # and must be explictly overwritten
        if [[ -z "${TERM_SESSION_ID}" ]] || [[ ! -z "$TMUX" ]] 
            then 
                export TERM_SESSION_ID="$(uuidgen)"
        fi
        export TTY=$(tty)
        export FIG_INTEGRATION_VERSION=1
        export FIG_ENV_VAR=1

        # Gives fig context for cwd in each window
        fig bg:init $$ $TTY

        # Check for prompts or onboarding 
        # must be last, so Fig has context for onboarding!
        [ -s ~/.fig/tools/prompts.sh ] && source ~/.fig/tools/prompts.sh

    fi


    # We use a shell variable to make sure this doesn't load twice
    if [ -z "$FIG_SHELL_VAR" ]
    then

        if [[ $BASH ]]
        then
            source ~/.fig/fig.bash

        elif [[ $ZSH_NAME ]]
        then
           source ~/.fig/fig.zsh

        fi
        FIG_SHELL_VAR=1
    fi

    # todo: Add a check to confirm "add-zle-hook-widget" facility exists
    # Not included in fig.zsh, because should be run last
    if [[ $ZSH_NAME ]]
        then
        source ~/.fig/zle.zsh
    fi
fi
