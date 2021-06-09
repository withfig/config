autoload -Uz add-zsh-hook

function fig_precmd_hook() { fig bg:prompt $$ $TTY &! }
add-zsh-hook precmd fig_precmd_hook

function fig_preexec_hook() { fig bg:exec $$ $TTY &! }
add-zsh-hook preexec fig_preexec_hook 
