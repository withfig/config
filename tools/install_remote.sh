#!/usr/bin/env bash
CONTROL_PATH="$1"
USER="$2"
HOST="$3"

REMOTE="${USER}@${HOST}"
REMOTE_HOME="${REMOTE}:~/"
TMP_HOME=/tmp/fig_remote_install/
RCS=(.zshrc .bashrc .profile .zprofile .bash_profile)

source ~/.fig/tools/install_helpers.sh

copy () {
  scp -r -o "ControlPath=${CONTROL_PATH}" "$@" > /dev/null 2>&1
}

remotecmd () {
  ssh -o "ControlPath=${CONTROL_PATH}" "${REMOTE}" "$@" > /dev/null 2>&1
}

rm -rf "${TMP_HOME}"
mkdir -p "${TMP_HOME}"
cp "${HOME}/.fig/shell/post.sh" "${TMP_HOME}fig.sh"
cp "${HOME}/.fig/shell/post.fish" "${TMP_HOME}fig.fish"

remotecmd "mkdir -p ~/.fig"
copy "${HOME}/.fig/shell" "${TMP_HOME}fig.sh" "${REMOTE_HOME}.fig/"

# Copy all files we update during install.
# TODO(sean) optimize and slim down number of files here to bare min for efficiency.
copy "${RCS[@]/#/$REMOTE_HOME}" "${TMP_HOME}"

for rc in "${RCS[@]}"; do
  fig_append fig.sh "${TMP_HOME}${rc}"
done

copy "${RCS[@]/#/$TMP_HOME}" "${REMOTE_HOME}"

remotecmd "mkdir -p ~/.config/fish/conf.d"
copy "${TMP_HOME}fig.fish" "${REMOTE_HOME}.config/fish/conf.d/99_fig_post.fish"
