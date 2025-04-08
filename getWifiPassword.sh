#!/bin/bash

# ssid=`/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I  | awk -F' SSID: '  '/ SSID: / {print $2}'`

# security find-generic-password -wa $ssid

#security find-generic-password -wa "$(networksetup -getairportnetwork en0 | cut -d ":" -f 2 | xargs)"

security find-generic-password -wa "$(system_profiler SPAirPortDataType | awk '/Current Network Information:/ { getline; print substr($0, 13, (length($0) - 13)); exit }')"