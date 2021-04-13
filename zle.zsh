zmodload zsh/system

# Integrate with ZSH line editor
autoload -U +X add-zle-hook-widget
function fig_zsh_keybuffer() { 
    # if [ ! -f ~/.fig/insertion-lock ] && [ $PENDING = "0" ]; then
    #     fig bg:zsh-keybuffer $CURSOR "$BUFFER" $HISTNO
    # fi

    if (( PENDING || KEYS_QUEUED_COUNT )); then
      if (( ! ${+_fig_redraw_fd} )); then
        typeset -gi _fig_redraw_fd
        if sysopen -o cloexec -ru _fig_redraw_fd /dev/null; then
          zle -F $_fig_redraw_fd fig_zsh_redraw
        else
          unset _fig_redraw_fd
        fi
      fi
    else
      fig_zsh_redraw
    fi
 }

function fig_zsh_redraw() {
    if (( ${+_fig_redraw_fd} )); then
      zle -F "$_fig_redraw_fd"
      exec {_fig_redraw_fd}>&-
      unset _fig_redraw_fd
    fi

    echo fig bg:zsh-keybuffer $TERM_SESSION_ID $FIG_INTEGRATION_VERSION $HISTNO $CURSOR \""$BUFFER"\" | base64 | nc -U /tmp/fig.socket
}

function fig_hide() { 
    fig bg:hide &!
}

# Delete any widget, if it already exists
add-zle-hook-widget line-pre-redraw fig_zsh_keybuffer

# Update keybuffer on new line
add-zle-hook-widget line-init fig_zsh_keybuffer

# Hide when going through history (see also: histno logic in ShellHooksManager.updateKeybuffer)
add-zle-hook-widget history-line-set fig_hide

# Hide when searching
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

# Bind to arbitrary unicode character
# If this changes, make sure to update coresponding keycode in ZLEIntegration.insert
# And increment $FIG_INTEGRATION_VERSION
bindkey '◧' fig_insert
