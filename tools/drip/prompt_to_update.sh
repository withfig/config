#!/usr/bin/env bash
MAGENTA=$(tput setaf 5)
NORMAL=$(tput sgr0)

if [[ "${FIG_IS_RUNNING}" -eq 1 && ! -z "${NEW_VERSION_AVAILABLE}" ]]; then
    DISABLE_AUTOPUPDATES="$(fig settings app.disableAutoupdates)"
    if [[ "${DISABLE_AUTOPUPDATES}" ==  "true" ]]; then
        echo "A new version of ${MAGENTA}Fig${NORMAL} is available. (Autoupdates are disabled)"
    else 
        (fig update:app --force > /dev/null &)
        echo "Updating ${MAGENTA}Fig${NORMAL} to latest version..."
    fi
fi

