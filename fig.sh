#!/usr/bin/env bash

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathadd ~/.fig/bin

if [[ -d /Applications/fig.app ]] || [[ -d ~/Applications/fig.app ]]  && command -v fig 1> /dev/null 2> /dev/null
then
    if [ -z "$FIG_ENV_VAR" ]
    then
        # Gives fig context for cwd in each window
        fig bg:init $$ $(tty)

        # Run aliases shell script
        [ -s ~/.fig/user/aliases/_myaliases.sh ] && source ~/.fig/user/aliases/*.sh

        # Check for prompts or onboarding
        [ -s ~/.fig/tools/prompts.sh ] && source ~/.fig/tools/prompts.sh


        # Generated automatically by iTerm and Terminal
        # But needs to be explicitly set for VSCode and Hyper
        if [ -z "${TERM_SESSION_ID}" ] 
            then 
                export TERM_SESSION_ID="$(uuidgen)"
        fi
        export TTY=$(tty)
        export FIG_ENV_VAR=1

    fi


    # We use a shell variable to make sure this doesn't load twice
    if [ -z "$FIG_SHELL_VAR" ]
    then

        if [[ $BASH ]]
        then
            # Set environment VAR

            if [[ ! $PROMPT_COMMAND == *"fig bg:prompt"* ]]
            then
                export PROMPT_COMMAND='(fig bg:prompt $$ $TTY &); '$PROMPT_COMMAND
            fi

            # https://superuser.com/a/181182
            trap '$(fig bg:exec $$ $(tty) &)' DEBUG 

        elif [[ $ZSH_NAME ]]
        then
            autoload -Uz add-zsh-hook

            function fig_precmd_hook() { (fig bg:prompt $$ $TTY &); }
            add-zsh-hook precmd fig_precmd_hook

            function fig_preexec_hook() { (fig bg:exec $$ $TTY &); }
            add-zsh-hook preexec fig_preexec_hook       
            

        fi
        FIG_SHELL_VAR=1
    fi
fi
