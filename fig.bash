if [[ "${PROMPT_COMMAND}" != *"fig bg:prompt"* ]]; then
  export PROMPT_COMMAND='(fig bg:prompt $$ $TTY &); '$PROMPT_COMMAND
fi

# https://superuser.com/a/181182
trap '$(fig bg:exec $$ $(tty) &)' DEBUG
