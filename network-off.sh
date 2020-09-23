networksetup -setairportpower Wi-Fi off
# blueutil --power 0 
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0 && \
            sudo killall -HUP bluetoothd