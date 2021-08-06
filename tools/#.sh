#!/usr/bin/env bash


# URL="http://localhost:3000/codex"
URL="https://waitlist.withfig.com/codex"


BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

CODE=$(tput setaf 153)

# Other colors
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)

# Weights and decoration
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
UNDERLINE_END=$(tput rmul)
HIGHLIGHT=$(tput smso)
HIGHLIGHT_END=$(tput rmso)
NORMAL=$(tput sgr0)


FIG="${BOLD}${MAGENTA}Fig${NORMAL}"

# Structure
TAB='   '
SEPARATOR="  \n\n  --\n\n\n"


print_special() {
	echo "${TAB}$@${NORMAL}"$'\n'
}




IN="$@"
ACCESS_TOKEN=$(defaults read com.mschrage.fig access_token)

if [[ -z "$ACCESS_TOKEN" ]]
then
	echo 
	print_special "${BOLD}${RED}Error${NORMAL}: you must be logged into Fig to use this"
	echo

	# TODO(brendan) What is the fig command to open the login window?

	exit 1
fi


# Request body to Fig endpoint
BODY=$(cat << END_HEREDOC
{
	"query": "$IN",
	"access_token": "$ACCESS_TOKEN"
}
END_HEREDOC
)



OUT=$(curl -fsSl \
--header "Content-Type: application/json" \
--request POST \
--data "$BODY" \
"$URL"
)


if [[ "$OUT" == "ERROR" ]] || [[ -z "$OUT" ]]
then
	echo 
	print_special "${BOLD}${RED}Error${NORMAL}: Something went wrong with this request"
	print_special "Please contact the $FIG team: ${UNDERLINE}hello@fig.io${NORMAL}"
	echo
	exit 1

fi

if [[ "$OUT" == "INVALID TOKEN" ]] || [[ -z "$OUT" ]]
then
	echo 
	print_special "${BOLD}${RED}Error${NORMAL}: Your $FIG access token is invalid"
	print_special "Please log out out Fig (using ${UNDERLINE}fig logout${NORMAL}) and trying logging in again"
	echo
	exit 1

fi


echo -n "$OUT" | pbcopy

# Final output
echo 
print_special "${UNDERLINE}Reponse by $FIG${UNDERLINE} and OpenAI Codex${NORMAL}"
print_special "$OUT"
echo
exit 1


echo $OUT


# border()
# {
#     title="| $1 |"
#     edge=$(echo "$title" | sed 's/./-/g')
#     echo "$edge"
#     echo "$title"
#     echo "$edge"
# }

# border "this is an excepetionally long string that will go over many lines but looks like normal english doesn't it"