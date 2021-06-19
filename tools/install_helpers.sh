fig_source() {
  printf "#### FIG ENV VARIABLES ####\n"
  printf "[ -s ~/.fig/$1 ] && source ~/.fig/$1\n"
  printf "#### END FIG ENV VARIABLES ####\n"
}

fig_append() {
  # Appends line to a config file to source file from the ~/.fig directory.
  # Usage: fig_append fig.sh path/to/rc
  # Don't append to files that don't exist to avoid creating file and
  # changing shell behavior.
  if [ -f "$2" ] && ! grep -q "source ~/.fig/$1" "$2"; then
    echo "$(fig_source $1)" >> "$2"
  fi
}

fig_prepend() {
  # Prepends line to a config file to source file from the ~/.fig directory.
  # Usage: fig_prepend fig_pre.sh path/to/rc
  # Don't prepend to files that don't exist to avoid creating file and
  # changing shell behavior.
  if [ -f "$2" ] && ! grep -q "source ~/.fig/$1" "$2"; then
    echo -e "$(fig_source $1)\n$(cat $2)" > $2
  fi
}

