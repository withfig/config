mkdir -p ~/.fig/

curl -Ls fig.sh/shell-integration.tar.gz | tar -x -C ~/.fig ||
  echo "Failed to download and extract shell integration" >&2 && exit 1

source ~/.fig/tools/install_utils.sh

append_to_profiles --no-prepend
echo Successfully installed fig shell integrations
[ -n "$FISH_VERSION" ] && source ~/.fig/post.fish || source ~/.fig/post.sh
