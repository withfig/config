#!/usr/bin/env bash

# Everytime we attempt a fix, there is a chance that other checks
# will be affected. Script should be re-run to ensure we are
# looking at an up to date environment.
function fix {
    echo "> $*"
    "$@"
    echo -e "\nFix applied!\n"
    "./$(basename "$0")" && exit
}

# TODO log applied fixes in /tmp
# If same fix is being applied twice, the fix is not working
# and we are in a loop. Script should be killed.
# Log to be cleared after each run

# TODO check for PORT 50000 issue

################
# check .zshrc #
################

# Check that Fig ENV vars are all in the right place. If not, remove them and put them back
# correctly.
vars_deleted=false
for file in ~/.profile ~/.zprofile ~/.bash_profile ~/.bashrc ~/.zshrc; do
    if [[ -f "$file" ]]; then
        # strip out whitespace and commented out lines
        clean_config=$(sed -e 's/^[ #\t]*//' $file | grep -v '^#')
        # all lines that source other files or directly manipulate the $PATH
        path_manip=$(echo "$clean_config" | grep -E 'PATH|source')

        first=$(echo "$path_manip" | sed -n '1p')
        last=$(echo "$path_manip" | sed -n '$p')

        if [[ $first != "[ -s ~/.fig/shell/pre.sh ] && source ~/.fig/shell/pre.sh" ]] || [[ $last != "[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh" ]]; then
            echo "Fig ENV variables need to be at the very beginning and end of $file"
            INSTALLATION1="#### FIG ENV VARIABLES ####"
            INSTALLATION2="\[ -s ~/.fig/shell/pre.sh ] && source ~/.fig/shell/pre.sh"
            INSTALLATION3="\[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh"
            INSTALLATION4="#### END FIG ENV VARIABLES ####"

            sed -i '' -e "s/$INSTALLATION1//g" $file
            sed -i '' -e "s#$INSTALLATION2##g" $file
            sed -i '' -e "s#$INSTALLATION3##g" $file
            sed -i '' -e "s/$INSTALLATION4//g" $file
            vars_deleted=true
        fi
    fi
done

# reinstall env variables in all shell configs
if [[ $vars_deleted == true ]]; then
    fix ./install_and_upgrade.sh
fi

# Check for unsupported themes
# unsupported: af-magic

zshrc=$(sed -e 's/^[ #\t]*//' "$HOME"/.zshrc | grep -v '^#')
if [[ $zshrc == *"af-magic"* ]]; then
    echo "af-magic is not a supported oh-my-zsh theme"
fi

########################
# check fig diagnostic #
########################

# run fig diagnostic and split output into lines
while IFS= read -ra line; do
    # for each line, split by ':' into the check and value
    IFS=: read -r check value <<<"${line[@]}"
    # strip leading and trailing whitespace from diagnostic value
    value=$(echo "$value" | xargs)

    case $check in
        "UserShell")
            if [[ $value != /bin/zsh ]]; then
                # TODO do something based on shell
                echo "Not using zsh"
            fi
            ;;
        "Bundle path")
            if [[ $value != /Applications/Fig.app ]]; then
                # TODO fix wrong bundle path
                echo "You need to install Fig in /Applications"
            fi
            ;;
        "Autocomplete")
            if [[ $value != true ]]; then
                # TODO fix missing autocomplete
                echo "Missing autocomplete"
            fi
            ;;
        "Settings.json")
            if [[ $value != true ]]; then
                # TODO fix missing settings.json
                echo "settings.json is missing!"
                fix ./install_and_upgrade.sh

            fi
            ;;
        "CLI installed")
            if [[ $value != "true" ]]; then
                # TODO fix missing CLI
                echo "Missing CLI"
            fi
            ;;
        "CLI tool path")
            if [[ $value != $HOME/.fig/bin/fig ]]; then
                # TODO fix wrong CLI tool path
                echo "Wrong CLI tool path"
            fi
            ;;
        "Accessibility")
            if [[ $value != true ]]; then
                # TODO fix accessibility
                echo "Accessibility not turned off"
            fi
            ;;
        "Number of specs")
            # Magic number 50 seems safe. Not sure what normal range of # specs is.
            if ((value < 50)); then
                echo "Autocomplete specs are missing!"
                fix fig update
            fi
            ;;
        "SSH Integration")
            if [[ $value != true ]]; then
                # TODO fix ssh
                echo "SSH not integrated"
            fi
            ;;
        "Tmux Integration")
            if [[ $value != true ]]; then
                # TODO fix tmux
                echo "tmux not integrated"
            fi
            ;;
        "Keybindings path")
            if [[ $value != $HOME/.fig/user/keybindings ]]; then
                # TODO fix keybindings
                echo "Keybindings not in correct place"
            fi
            ;;
        "iTerm Integration")
            if [[ $value != *"true"* ]]; then
                # check if Hyper is installed
                if eval "$(mdfind "kMDItemKind == 'Application'" | grep "iTerm.app")" 2>/dev/null; then
                    iterm_installed=true
                else
                    iterm_installed=false
                fi

                # only care about integration if iTerm is installed
                if [[ $iterm_installed == true ]]; then
                    echo "The iTerm integration is not installed!"
                    fix fig integrations:iterm
                fi
            fi
            ;;
        "Hyper Integration")
            if [[ $value != true ]]; then
                # check if Hyper is installed
                if eval "$(mdfind "kMDItemKind == 'Application'" | grep "Hyper.app")" 2>/dev/null; then
                    hyper_installed=true
                else
                    hyper_installed=false
                fi

                # only care about integration if Hyper is installed
                if [[ $hyper_installed == true ]]; then
                    # TODO fix Hyper
                    echo "Hyper not integrated"
                fi
            fi
            ;;
        "VSCode Integration")
            if [[ $value != true ]]; then
                # check if VSCode is installed
                if eval "$(mdfind "kMDItemKind == 'Application'" | grep "Visual Studio Code.app")" 2>/dev/null; then
                    vscode_installed=true
                else
                    vscode_installed=false
                fi

                # only care about integration if VSCode is installed
                if [[ $vscode_installed == true ]]; then
                    # TODO fix VSCode
                    echo "VSCode not integrated"
                fi
            fi
            ;;
        "Docker Integration")
            if [[ $value != true ]]; then
                # check if docker is installed
                if docker -v 2>/dev/null; then
                    docker_installed=true
                else
                    docker_installed=false
                fi

                # only care about integration if docker is installed
                if [[ $docker_installed == true ]]; then
                    # TODO fix Docker
                    echo "Docker not integrated"
                fi
            fi
            ;;
        "Symlinked dotfiles")
            # if [[ $value != true ]]; then
            # TODO anything to do here?
            # fi
            ;;
        "Only insert on tab")
            if [[ $value == true ]]; then
                # TODO anything to do here?
                echo "Fig is inserted on tab"
            fi
            ;;
        "Installation Script")
            if [[ $value != true ]]; then
                # TODO fix missing installation script
                echo "Missing the installation script!"
                fix fig util:install-script
            fi
            ;;
        "PseudoTerminal Path")
            pseudo_terminal_path=$value
            ;;
        "PATH")
            if [[ $value != "$pseudo_terminal_path" ]]; then
                echo "Your PATH and Fig's pseudo terminal path do not match!"
                fix fig set:path
            fi
            ;;
        "SecureKeyboardInput")
            secure_keyboard_input=$value
            ;;
        "SecureKeyboardProcess")
            if [[ $secure_keyboard_input == true ]]; then
                # TODO fix Secure keyboard input
                echo "Secure keyboard input is on"
                echo "Secure keyboard process is$value"
            fi
            ;;
        "Current active process")
            if [[ $value == *"?"* ]]; then
                # TODO fix current active process
                echo "Can't find current active process"
            fi
            ;;
        "Current working directory")
            if [[ $value == *"?"* ]]; then
                # TODO fix current active directory
                echo "Can't find current active directory"
            fi
            ;;
        "Current window identifier")
            if [[ $value == *"?"* ]]; then
                # TODO fix current window identifier
                echo "Can't find current window identifier"
                echo -e "\nAre you running a supported terminal? [eg: Terminal, iTerm, VSCode, Hyper]"
            fi
            ;;
        "FIG_INTEGRATION_VERSION")
            if [[ $value != 4 ]]; then
                # TODO fix incorrect FIG_INTEGRATION_VERSION
                echo "Current FIG_INTEGRATION_VERSION = 4"
            fi
            ;;
    esac
done <<<"$(fig diagnostic)"

#####################
# check for updates #
#####################

# Can we get latest version before running?
# echo "Checking for updates!"

# TODO check for SSH

###########################
# additional help prompts #
###########################

echo -e "\nFig still not working?"

echo "Run 'fig issue' to let us know!"
echo "Or email us at hello@fig.io!"
