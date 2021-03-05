#!/usr/bin/env bash

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathadd ~/.fig/bin

if ([[ -d /Applications/fig.app ]] || [[ -d ~/Applications/fig.app ]])  && [ ! "$TERMINAL_EMULATOR" = JetBrains-JediTerm ] && command -v fig 1> /dev/null 2> /dev/null
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

    # todo: Add a check to confirm "add-zle-hook-widget" facility exists
    if [[ $ZSH_NAME ]]
        then
            # Integrate with ZSH line editor
            autoload -U +X add-zle-hook-widget
            function fig_zsh_keybuffer() { 
                if [ ! -f ~/.fig/insertion-lock ]; then
                    fig bg:zsh-keybuffer $CURSOR "$BUFFER" $HISTNO &!
                fi
             }

            function fig_hide() { 
                fig bg:hide &!
            }

            # Delete any widget, if it already exists
            add-zle-hook-widget -D line-pre-redraw fig_zsh_keybuffer
            add-zle-hook-widget line-pre-redraw fig_zsh_keybuffer

            # Update keybuffer on new line
            add-zle-hook-widget -D line-init fig_zsh_keybuffer
            add-zle-hook-widget line-init fig_zsh_keybuffer

            # Hide when going through history (see also: histno logic in ShellHooksManager.updateKeybuffer)
            add-zle-hook-widget -D history-line-set fig_hide
            add-zle-hook-widget history-line-set fig_hide

            # Hide when searching
            add-zle-hook-widget -D isearch-update fig_hide
            add-zle-hook-widget isearch-update fig_hide

            # Create insertion facility
            function fig_insert () {
                immediate=$(< ~/.fig/zle/immediate)
                insertion=$(< ~/.fig/zle/insert)
                deletion=$(< ~/.fig/zle/delete)
                offset=$(< ~/.fig/zle/offset)

                if [ ! $deletion = "0" ]; then
                    LBUFFER=${LBUFFER:0:-deletion}
                fi

                RBUFFER=${insertion}${RBUFFER}
                CURSOR=$CURSOR+${#insertion}-$offset

                if [ $immediate = "1" ]; then
                    zle accept-line
                fi

            }

            zle -N fig_insert

            # Bind to fn12 - Hyper and VScode don't support fn13+
            # If this changes, make sure to update coresponding keycode in ZLEIntegration.insert
            bindkey '^[[24~' fig_insert
            
    fi
fi
