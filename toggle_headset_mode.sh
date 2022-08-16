#!/bin/bash

#off: Off (sinks: 0, sources: 0, priority: 0, available: yes)
#a2dp-sink: High Fidelity Playback (A2DP Sink) (sinks: 1, sources: 0, priority: 16, available: yes)
#headset-head-unit: Headset Head Unit (HSP/HFP) (sinks: 1, sources: 1, priority: 1, available: yes)
#a2dp-sink-sbc: High Fidelity Playback (A2DP Sink, codec SBC) (sinks: 1, sources: 0, priority: 18, available: yes)
#a2dp-sink-sbc_xq: High Fidelity Playback (A2DP Sink, codec SBC-XQ) (sinks: 1, sources: 0, priority: 17, available: yes)
#a2dp-sink-aac: High Fidelity Playback (A2DP Sink, codec AAC) (sinks: 1, sources: 0, priority: 19, available: yes)
#a2dp-sink-aptx: High Fidelity Playback (A2DP Sink, codec aptX) (sinks: 1, sources: 0, priority: 20, available: yes)
#a2dp-sink-aptx_hd: High Fidelity Playback (A2DP Sink, codec aptX HD) (sinks: 1, sources: 0, priority: 21, available: yes)
#a2dp-sink-ldac: High Fidelity Playback (A2DP Sink, codec LDAC) (sinks: 1, sources: 0, priority: 22, available: yes)
#headset-head-unit-cvsd: Headset Head Unit (HSP/HFP, codec CVSD) (sinks: 1, sources: 1, priority: 2, available: yes)
#headset-head-unit-msbc: Headset Head Unit (HSP/HFP, codec mSBC) (sinks: 1, sources: 1, priority: 3, available: yes)

#icons found here: /usr/share/icons/gnome/32x32

# Toggle your bluetooth device (e.g., Bose Headphones) between A2DP mode (high-fidelity playback with NO microphone) and HSP/HFP, codec mSBC (lower playback quality, microphone ENABLED)
function tbt {
    current_mode_is_a2dp=`pactl list | grep Active | grep a2dp`
    card=`pactl list | grep "Name: bluez_card." | cut -d ' ' -f 2`

    #test if card is empty
    if [ -z "$card" ]; then
        if zenity --question --icon-name=error --text="No bluetooth device found, Do you want to restart bluetooth?"
        then
            sudo systemctl restart bluetooth
        else
            echo "User rejected"
        fi
        return 1
    fi

    if [ -n "$current_mode_is_a2dp" ]; then
        echo "Switching $card to mSBC (headset, for making calls)..."
        notify-send -i audio-headset -h int:transient:1 "Switching to headset mode"
        pactl set-card-profile $card headset-head-unit-msbc
    else
        echo "Switching $card to A2DP (high-fidelity playback)..."
        notify-send -i audio-headphones -h int:transient:1 "Switching to music mode"
        pactl set-card-profile $card a2dp-sink-ldac
    fi
}

tbt
