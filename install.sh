#!/bin/bash

chmod +x *.sh *.py
sudo patch -b /boot/config.txt 7inch.patch
sudo apt-get install -y python3-pip libudev-dev
sudo pip-3.2 install python-uinput pyudev

sudo cp touch.py /usr/bin/
sudo cp touch.sh /etc/init.d/

chmod +x /usr/bin/touch.py
chmod +x /etc/init.d/touch.sh

sudo update-rc.d touch.sh defaults