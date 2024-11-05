#!/bin/bash

# Function to send GNOME notification
notify() {
    local summary="$1"
    local body="$2"
    local icon="$3"
    gdbus call --session \
        --dest=org.freedesktop.Notifications \
        --object-path=/org/freedesktop/Notifications \
        --method=org.freedesktop.Notifications.Notify \
        "bluetooth-switch" 0 "$icon" "$summary" "$body" "[]" "{}" 2000 >/dev/null
}

# Function to toggle bluetooth profile between A2DP and HSP/HFP
function toggle_bt_profile {
    # Get current profile
    current_profile=$(pactl list cards | grep -e "Name: bluez_card" -e "Active Profile" | grep -A1 "bluez_card.80_99_E7_57_69_13" | grep "Active Profile" | cut -d ' ' -f 3-)
    echo "Current profile: $current_profile"

    # Toggle between profiles
    if [ "$current_profile" = "a2dp-sink" ]; then
        echo "Switching to mSBC headset mode..."
        pactl set-card-profile bluez_card.80_99_E7_57_69_13 headset-head-unit-msbc
        notify "Headset Mode" "Microphone enabled" "audio-headset"
    else
        echo "Switching to A2DP mode..."
        pactl set-card-profile bluez_card.80_99_E7_57_69_13 a2dp-sink
        notify "High-Fidelity Mode" "Best audio quality" "audio-headphones"
    fi

    # Verify the switch
    sleep 0.5
    new_profile=$(pactl list cards | grep -e "Name: bluez_card" -e "Active Profile" | grep -A1 "bluez_card.80_99_E7_57_69_13" | grep "Active Profile" | cut -d ' ' -f 3-)
    echo "New profile: $new_profile"
}

# Run the toggle function
toggle_bt_profile