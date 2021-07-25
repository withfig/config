#!/usr/bin/env bash

################
# check .zshrc #
################

# print uncommented .zshrc
zshrc=$(grep -v '^#' ~/.zshrc)

# Check for unsupported themes
# unsupported: af-magic

if [[ $zshrc == *"af-magic"* ]]; then
    echo "af-magic is not a supported oh-my-zsh theme"
fi

########################
# check fig diagnostic #
########################

while IFS= read -ra line; do
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
                echo -e "Let's run install script to add a new settings.json.\n"
                ./install_and_upgrade.sh
                echo -e "Fix applied!\n"
                "./$(basename "$0")" && exit
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
                echo -e "Let's run 'fig update' to download the all autocomplete specs.\n"
                echo "fig update"
                fig update
                echo -e "Fix applied!\n"
                "./$(basename "$0")" && exit
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
            if [[ $value != true ]]; then
                # check if Hyper is installed
                if mdfind "kMDItemKind == 'Application'" | grep "iTerm.app" | 2>/dev/null; then
                    iterm_installed=true
                else
                    iterm_installed=false
                fi

                # only care about integration if iTerm is installed
                if [[ $iterm_installed == true ]]; then
                    echo "Integrating iTerm!"
                    fig integrations:iterm
                fi
            fi
            ;;
        "Hyper Integration")
            if [[ $value != true ]]; then
                # check if Hyper is installed
                if mdfind "kMDItemKind == 'Application'" | grep "Hyper.app" | 2>/dev/null; then
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
                if mdfind "kMDItemKind == 'Application'" | grep "Visual Studio Code.app" | 2>/dev/null; then
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
            if [[ $value != true ]]; then
                # TODO anything to do here?
                echo "dotfiles are not symlinked" | 2>/dev/null
            fi
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
                echo "Missing installation script"
            fi
            ;;
        "PseudoTerminal Path")
            pseudo_terminal_path=$value
            ;;
        "PATH")
            if [[ $value != "$pseudo_terminal_path" ]]; then
                echo "Setting pseudo terminal path!"
                fig set:path
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
            if [[ $value == ??? ]]; then
                # TODO fix current active process
                echo "Can't find current active process"
            fi
            ;;
        "Current working directory")
            if [[ $value == ??? ]]; then
                # TODO fix current active directory
                echo "Can't find current active directory"
            fi
            ;;
        "Current window identifier")
            if [[ $value == ??? ]]; then
                # TODO fix current window identifier
                echo "Can't find current window identifier"
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

###########################
# additional help prompts #
###########################

echo "Fig still not working?"
echo "Run 'fig issue' to let us know!"

echo "$FIG_IS_RUNNING"
