#!/usr/bin/env bash
MAGENTA=$(tput setaf 5)
NORMAL=$(tput sgr0)

if [[ "$(fig app:running)" -eq 1 && ! -z "${NEW_VERSION_AVAILABLE}" ]]; then
    (fig update:app --force > /dev/null &)
    echo "Updating ${MAGENTA}Fig${NORMAL} to latest version..."
fi

