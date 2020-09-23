networksetup -setairportpower Wi-Fi on
# blueutil --power 1 
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 1 && \
            sudo killall -HUP bluetoothd