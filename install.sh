#!/bin/bash


# For checking version numbers greater than or equal.
check_ver_lte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}


chmod +x *.sh *.py
sudo ./update_boot_config
sudo apt-get install -y python3-pip libudev-dev
sudo pip3 install python-uinput pyudev

PYTHON_VERSION=`python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'`
if check_ver_lte "3.4" $PYTHON_VERSION; then
    echo "Python $PYTHON_VERSION detected - using async driver."
    sudo cp touch_async.py /usr/bin/touch.py
else
    sudo cp touch.py /usr/bin/
fi
sudo cp touch.sh /etc/init.d/

sudo chmod +x /usr/bin/touch.py
sudo chmod +x /etc/init.d/touch.sh

sudo update-rc.d touch.sh defaults
