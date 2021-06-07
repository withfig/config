#!/usr/bin/env bash

#  remote_cwd.sh
#  fig
#
#  Created by Matt Schrage on 1/7/21.
#  Copyright © 2021 Matt Schrage. All rights reserved.


# Notes:
# This script either outputs "error" or it outputs the working directory of the user's remote shell
# The script has some Fig Settings passed in. These are
# * get_process_from_top -> if exists, get pid from the top of process list not bottom 

# Do not delete the following comment:
# FIG_SETTINGS


# OLD WAY OF DOING IT
# Heuristic for getting user's pid. Find all processes with a TTY and pick most recent.
# pid=$(ps -e -o pid,tty,comm | grep -v "?" | grep 'zsh\|bash\|fish' | tail -n -1 | xargs | cut -d ' ' -f 1);



# Steps (comment out all the code blocks when ready)

# 1. get the list of all processes
shell_processes=$(ps -e -o pid,tty,comm | grep -v "?" | grep 'zsh\|bash\|fish')

# 2. Work out how many TTYs there are on the remote machine
# NOTE: Do NOT delete the double quotes around "$shell_processes". The passing is wrong if we do
total_ttys=$(echo "$shell_processes" | awk '{print $2}' | sort | uniq | wc -l | awk '{print $1}')

# 3. Check how many TTYs are connected
# If more than 1, return some error code
if (( $total_ttys > 1 ));
then
        echo "error" 

# Otherwise, get the pid of the user's shell depending on the env variables / fig settings fig passed in
else 
        # If the user is using something like powerlevel10k or the train tracks prompt
        if [[ ! -z "$get_process_from_top" ]]; 
        then 
                pid=$(echo "$shell_processes" | head -n 1 | xargs | cut -d ' ' -f 1);

        # Otherwise get last process in list
        else
                pid=$(echo "$shell_processes" | tail -n -1 | xargs | cut -d ' ' -f 1);
        fi


        # https://stackoverflow.com/a/8597411/926887
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                readlink /proc/$pid/cwd
        elif [[ "$OSTYPE" == "darwin"* ]]; then
                lsof -p $pid | grep cwd | awk '{print $9}'
        elif [[ "$OSTYPE" == "cygwin" ]]; then
                pwd # not gonna handle this right now
        elif [[ "$OSTYPE" == "msys" ]]; then
                pwd # not gonna handle this right now
        elif [[ "$OSTYPE" == "win32" ]]; then
                pwd # not gonna handle this right now
        elif [[ "$OSTYPE" == "freebsd"* ]]; then
                procstat -f $pid | grep cwd | awk '{print $10}'
        else
            echo "error" # Unknown.
        fi
fi
