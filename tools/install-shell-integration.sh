mkdir -p ~/.fig/

error() {
  echo "Error: $@" >&2
  exit 1
}

cd ~/.fig/
curl -Ls fig.sh/shell-integration.tar.gz | tar -x ||
  error "Failed to download and extract shell integration"

source ~/.fig/tools/install_utils.sh

append_to_profiles
echo success
