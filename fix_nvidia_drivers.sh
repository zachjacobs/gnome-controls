#!/bin/bash




#sudo apt-get remove --purge '^nvidia-.*'
#sudo apt-get remove --purge '^libnvidia-.*'
#sudo apt-get remove --purge '^cuda-.*'
#Then after it’s clean ran that:
#sudo apt-get install linux-headers-$(uname -r)

#From here - it’s the same for all VMs:
#Download latest run 1.9k file from Nvidia site, and run it, accept if needed to upgrade current, or install from scratch.
#The driver is back to work.

#The issue was started after did some updates, and the Linux kernel was changed.

#https://developer.nvidia.com/cuda-downloads



sudo apt update
sudo apt-get remove --purge '^nvidia-.*' -y
sudo apt-get install ubuntu-desktop -y 
sudo apt install nvidia-driver-515-open -y

sudo nvidia-smi

