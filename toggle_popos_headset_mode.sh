#!/bin/bash

# Function to toggle bluetooth profile between A2DP and HSP/HFP
function toggle_bt_profile {
    # Get current profile
    current_profile=$(pactl list cards | grep -e "Name: bluez_card" -e "Active Profile" | grep -A1 "bluez_card.80_99_E7_57_69_13" | grep "Active Profile" | cut -d ' ' -f 3-)
    echo "Current profile: $current_profile"

    # Toggle between profiles
    if [ "$current_profile" = "a2dp-sink" ]; then
        echo "Switching to mSBC headset mode..."
        pactl set-card-profile bluez_card.80_99_E7_57_69_13 headset-head-unit-msbc
        zenity --info \
            --title="Profile Switched" \
            --icon-name=audio-headset \
            --text="Switched to Headset Mode\n(Microphone enabled)" \
            --width=300
    else
        echo "Switching to A2DP mode..."
        pactl set-card-profile bluez_card.80_99_E7_57_69_13 a2dp-sink
        zenity --info \
            --title="Profile Switched" \
            --icon-name=audio-headphones \
            --text="Switched to High-Fidelity Mode\n(Best audio quality)" \
            --width=300
    fi

    # Verify the switch
    sleep 0.5
    new_profile=$(pactl list cards | grep -e "Name: bluez_card" -e "Active Profile" | grep -A1 "bluez_card.80_99_E7_57_69_13" | grep "Active Profile" | cut -d ' ' -f 3-)
    echo "New profile: $new_profile"
}

# Run the toggle function
toggle_bt_profile