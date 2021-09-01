#!/usr/bin/env bash
#set -e

# This is the fig installation script. It runs just after you sign in for the
# first time.

# Replace TAG_NAME with the commit hash, git tag (like v1.0.25), or leave empty
# This script should be run via curl:
#   sh <(curl -fsSL https://raw.githubusercontent.com/withfig/config/main/tools/install_and_upgrade.sh) TAG_NAME
# or via wget:
#   sh <(wget -qO- https://raw.githubusercontent.com/withfig/config/main/tools/install_and_upgrade.sh) TAG_NAME
# or via fetch:
#   sh <(fetch -o - https://raw.githubusercontent.com/withfig/config/main/tools/install_and_upgrade.sh) TAG_NAME

FIGREPO='https://github.com/withfig/config.git'

# We are constantly pushing changes to the public repo.  Each version of the
# swift app is only compatible with a certain version of the public repo.
# The commit hash is passed in as a parameter to this script.  We hard reset to
# this commit hash. If we don't get a hash, we just hard reset to the most
# recent version of the repo...
FIG_TAG="$1"
if [[ -z "${FIG_TAG}" ]]; then
  FIG_TAG="main"
fi

echo "Tag is ${FIG_TAG}"
date_string=$(date '+%Y-%m-%d_%H-%M-%S')

error() {
  echo "Error: $@" >&2
  exit 1
}

# TODO(sean) add backup for ssh config (not currently done in this file)
fig_backup() {
  full_path=$1
  name=$2
  if [[ -e "${full_path}" ]]; then
    backup_dir="${HOME}/.fig.dotfiles.bak/${date_string}"
    mkdir -p $backup_dir

    cp $full_path "${backup_dir}/${name}" || error "Failed to backup file $1"
  fi
}

# Install fig. Override if already exists
install_fig() {
  # Create fig dir an cd into it
  mkdir -p ~/.fig

  # delete binary artifacts to ensure ad-hoc code signature works for arm64 binaries on M1
  rm ~/.fig/bin/figterm
  rm ~/.fig/bin/fig_callback
  rm ~/.fig/bin/fig_get_shell
  rm ~/.fig/bin/*'(figterm)'

  if [[ "${FIG_TAG}" == "local" ]]; then
    cp -R "$PWD"/* ~/.fig
    cd ~/.fig
  else
    cd ~/.fig
    curl "https://codeload.github.com/withfig/config/tar.gz/${FIG_TAG}" \
      | tar -xz --strip-components=1 \
      || (
        echo "downloading from main instead of fig tag_name" \
          && curl https://codeload.github.com/withfig/config/tar.gz/main \
            | tar -xz --strip-components=1 \
        ) \
      || error "pulling withfig/config repo failed"
  fi

  mkdir -p ~/.fig/autocomplete
  cd ~/.fig/autocomplete

  AUTOCOMPLETE_VERSION=$(defaults read com.mschrage.fig "autocompleteVersion" 2>/dev/null) ;

  curl -s "https://waitlist.withfig.com/specs?version=$AUTOCOMPLETE_VERSION" \
    | tar -xz --strip-components=1 specs \
    || error "pulling latest autocomplete files failed"

  # Make files and folders that the user can edit (that aren't overridden by above)
  mkdir -p ~/.fig/{bin,zle}
  mkdir -p ~/.fig/user/{aliases,apps,autocomplete,aliases}

  if [[ ! -f ~/.fig/settings.json ]]; then
    echo "{}" > ~/.fig/settings.json
  fi

  touch ~/.fig/user/aliases/_myaliases.sh

  # Figpath definition.
  touch ~/.fig/user/figpath.sh

  # Determine user's login shell by explicitly reading from "/Users/$(whoami)"
  # rather than ~ to handle rare cases where these are different.
  USER_SHELL="$(dscl . -read /Users/$(whoami) UserShell)"
  defaults write com.mschrage.fig userShell "${USER_SHELL}"

  USER_SHELL_TRIMMED="$(echo "${USER_SHELL}" | cut -d ' ' -f 2)"

  # Hardcode figcli path because symlinking has not happened when this script
  # runs.
  FIGCLI=/Applications/Fig.app/Contents/MacOS/figcli 
  "${FIGCLI}" settings userShell "${USER_SHELL_TRIMMED}"
  
  "${FIGCLI}" settings pty.path $("${USER_SHELL_TRIMMED}" -li -c "/usr/bin/env | /usr/bin/grep '^PATH=' | /bin/cat | /usr/bin/sed 's|PATH=||g'") 

  # hotfix for infinite looping when writing "☑ fig" title to a tty backed by figterm
  "${FIGCLI}" settings autocomplete.addStatusToTerminalTitle false

  # Restart file watcher
  "${FIGCLI}" settings:init

  # Define the figpath variable in the figpath file
  # The file should look like this:
  #   export FIGPATH="~/.fig/bin:~/run:"
  #   FIGPATH=$FIGPATH'~/abc/de fg/hi''~/zyx/wvut'
  if ! grep -q 'FIGPATH=$FIGPATH' ~/.fig/user/figpath.sh; then 
    echo $'\n''FIGPATH=$FIGPATH' >> ~/.fig/user/figpath.sh
  fi
}

fig_source() {
  printf "\n#### FIG ENV VARIABLES ####\n"
  if [[ -n $2 ]]; then
    printf "# $2\n"
  fi
  printf "[ -s ~/.fig/$1 ] && source ~/.fig/$1\n"
  printf "#### END FIG ENV VARIABLES ####\n"
}

fig_append() {
  # Appends line to a config file to source file from the ~/.fig directory.
  # Usage: fig_append fig.sh path/to/rc
  # Don't append to files that don't exist to avoid creating file and
  # changing shell behavior.
  if [ -f "$2" ] && ! grep -q "source ~/.fig/$1" "$2"; then
    echo "$(fig_source $1 "Please make sure this block is at the end of this file.")" >> "$2"
  fi
}

fig_prepend() {
  # Prepends line to a config file to source file from the ~/.fig directory.
  # Usage: fig_prepend fig_pre.sh path/to/rc
  # Don't prepend to files that don't exist to avoid creating file and
  # changing shell behavior.
  if [ -f "$2" ] && ! grep -q "source ~/.fig/$1" "$2"; then
    echo "$(fig_source $1 "Please make sure this block is at the start of this file.")" | cat - "$2" > "/tmp/fig_prepend" && cat "/tmp/fig_prepend" > "$2"
  fi
}

# Add the fig.sh to your profiles so it can be sourced on new terminal window load
append_to_profiles() {
  # Make sure one of [.bash_profile|.bash_login|.profile] exists to ensure fig
  # is sourced on login shells. We choose .profile to be as minimally
  # disruptive to existing user set up as possible.
  # https://superuser.com/questions/320065/bashrc-not-sourced-in-iterm-mac-os-x
  touch "${HOME}/.profile"

  # Replace old sourcing in profiles.
  for rc in .profile .zprofile .bash_profile; do
    if [[ -e "${HOME}/${rc}" ]]; then
      # Ignore failures if we don't find old contents.
      sed -i '' 's/~\/.fig\/exports\/env.sh/~\/.fig\/fig.sh/g' "${HOME}/${rc}" 2> /dev/null || :
    fi
  done
  

  # Create .zshrc/.bashrc regardless of whether it exists or not
  touch "${HOME}/.zshrc" "${HOME}/.bashrc"

  # Don't modify files until all are backed up.
  for rc in .profile .zprofile .bash_profile .bash_login .bashrc .zshrc; do
    fig_backup "${HOME}/${rc}" "${rc}"
  done

  for rc in .profile .zprofile .bash_profile .bash_login .bashrc .zshrc; do
    fig_prepend shell/pre.sh "${HOME}/${rc}"
    fig_append fig.sh "${HOME}/${rc}"
  done

  # Handle fish separately.
  mkdir -p ~/.config/fish/conf.d

  # Use 00_/99_ prefix to load script earlier/later in fish startup.
  ln -sf ~/.fig/shell/pre.fish ~/.config/fish/conf.d/00_fig_pre.fish
  ln -sf ~/.fig/shell/post.fish ~/.config/fish/conf.d/99_fig_post.fish

  # Remove deprecated fish config file.
  if [[ -f -~/.config/fish/conf.d/fig.fish ]]; then
    rm ~/.config/fish/conf.d/fig.fish
  fi
}

setup_onboarding() {
  # Create config file if it doesn't exist.
  if [[ ! -s ~/.fig/user/config ]]; then
    touch ~/.fig/user/config 
  fi

  # If this is first download, mark download time as now.
  grep -q 'DOWNLOAD_TIME' ~/.fig/user/config || echo "DOWNLOAD_TIME=$(date +'%s')" >> ~/.fig/user/config

  # Create last_update if it doesn't exist and mark last update as now.
  grep -q 'LAST_UPDATE' ~/.fig/user/config || echo "LAST_UPDATE=$(date +'%s')" >> ~/.fig/user/config
  sed -i '' "s/LAST_UPDATE=.*/LAST_UPDATE=$(date +'%s')/g" ~/.fig/user/config 2> /dev/null

  add_conf_var() { grep -q "$1" ~/.fig/user/config || echo "$1=0" >> ~/.fig/user/config ; }

  add_conf_var FIG_LOGGED_IN
  add_conf_var FIG_ONBOARDING
  add_conf_var DONT_SHOW_DRIP
  for num in ONE TWO THREE FOUR FIVE SIX SEVEN; do
    add_conf_var "DRIP_${num}"
  done
}

install_tmux_integration() {
  TMUX_INTEGRATION=$'\n# Fig Tmux Integration: Enabled\nsource-file ~/.fig/tmux\n# End of Fig Tmux Integration'

  # TODO: check if ~/.tmux.conf exists before appending to it
  fig_backup "${HOME}/.tmux.conf" ".tmux.conf"
  if ! grep -q 'source-file ~/.fig/tmux' ~/.tmux.conf; then 
    echo "${TMUX_INTEGRATION}" >> ~/.tmux.conf
  fi
}

# hotfix for infinite looping when writing "☑ fig" title to a tty backed by figterm
disable_setting_tty_title() {
  defaults write com.mschrage.fig addIndicatorToTitlebar false
}

install_fig
append_to_profiles
setup_onboarding
install_tmux_integration
disable_setting_tty_title
echo success
