function fig_precmd --on-event fish_prompt
    fig bg:prompt $fish_pid (tty) &
end

function fig_preexec --on-event fish_preexec
    fig bg:exec $fish_pid (tty) &
end
