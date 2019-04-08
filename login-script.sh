#!/bin/bash
# do shell script 'open -n /usr/local/bin/code "/Users/livshitz/Library/Mobile Documents/com~apple~CloudDocs/Desktop/meta"'

open -n "/Applications/Visual Studio Code.app/" --args '-n' '/Users/livshitz/Library/Mobile Documents/com~apple~CloudDocs/Desktop/meta' '--new-window' '--user-data-dir=/Users/livshitz/.vscode'
# osascript -e 'tell application "Terminal" to close first window' & exit

# osacompile -e 'do shell script "open -n /usr/local/bin/code"' 