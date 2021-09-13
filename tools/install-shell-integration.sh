mkdir -p ~/.fig/

curl -Ls fig.sh/shell-integration.tar.gz | tar -x -C ~/.fig ||
  echo "Failed to download and extract shell integration" >&2 && exit 1

~/.fig/tools/install_integrations.sh --minimal

echo Successfully installed fig shell integrations
[ -n "$FISH_VERSION" ] && source ~/.fig/post.fish || source ~/.fig/post.sh
