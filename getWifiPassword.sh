#!/bin/bash

# ssid=`/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I  | awk -F' SSID: '  '/ SSID: / {print $2}'`

# security find-generic-password -wa $ssid

security find-generic-password -wa "$(networksetup -getairportnetwork en0 | cut -d ":" -f 2 | xargs)"