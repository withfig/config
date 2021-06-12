#!/usr/bin/env bash

# Read all the user defaults.
if [[ -s ~/.fig/user/config ]]; then
  source ~/.fig/user/config 
else
  return
fi

# To update a specific variable:
# sed -i '' "s/FIG_VAR=.*/FIG_VAR=1/g" ~/.fig/user/config 2> /dev/null

# Check if onboarding variable is empty or not
# if [[ -z "$FIG_ONBOARDING" ]]; then
#   # Is empty. Set it to false
#   grep -q 'FIG_ONBOARDING' ~/.fig/user/config || echo "FIG_ONBOARDING=0" >> ~/.fig/user/config
# fi

# https://unix.stackexchange.com/questions/290146/multiple-logical-operators-a-b-c-and-syntax-error-near-unexpected-t
if  [[ "$FIG_ONBOARDING" == '0' ]] \
  && ([[ "$TERM_PROGRAM" == "iTerm.app" ]] \
    || [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]); then
  # Check if we're logged in.
  if [[ "$FIG_LOGGED_IN" == '0' ]]; then
    # If we are actually logged in, update accordingly and run onboarding campaign.
    if [[ -n $(defaults read com.mschrage.fig userEmail 2> /dev/null) ]]; then
      sed -i '' "s/FIG_LOGGED_IN=.*/FIG_LOGGED_IN=1/g" ~/.fig/user/config 2> /dev/null
      if [[ -s ~/.fig/tools/drip/fig_onboarding.sh ]]; then
        ~/.fig/tools/drip/fig_onboarding.sh 
      fi
    fi
  else
    # If we are logged in, proceed as usual.
    if [[ -s ~/.fig/tools/drip/fig_onboarding.sh ]]; then
				  ~/.fig/tools/drip/fig_onboarding.sh 
    fi
  fi
fi

# In the future we will calculate when a user signed up and if there are any
# drip campaigns remaining for the user. We will hardcode time since sign up
# versus drip campaign date here.
