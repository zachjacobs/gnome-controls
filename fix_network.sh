#!/bin/bash

echo "attempting to fix network bridge"

nmcli con down Wired\ connection\ 1
nmcli con up bridge-br0
nmcli con up bridge-slave-enp5s0

nmcli connection show --active
