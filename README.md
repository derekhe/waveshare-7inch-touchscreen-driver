Updated
=======================
Original driver and README at:  https://github.com/derekhe/waveshare-7inch-touchscreen-driver.git

WaveShare 7-inch user space driver
===================================
OP brought a [WaveShare 7-inch HDMI LCD](http://www.waveshare.net/shop/7inch-HDMI-LCD-B.htm) and it provides a USB touchscreen.
But the company only provide binary driver and images, which is quite bad. Installing binary driver will break self compiled kernel, and you can't get updated kernels.
OP asked the company to provide the source code but they refused. They said they won't provide any source code because other companies can copy very fast so that their products can't sell out at good price.

OK. If they company won't want to provide anything, that's fine. OP finally find out we can still drive the touchscreen by writing a user space driver.

**NOTE: I do not guarantee this driver will work on other system/other displays. If you have trouble, or make it work on other system/displays, please make a pull request, I'll help to merge it into master branch.**

**If any help needed, do not send an email to me directly, please raise an issue so that your question can be solved quicker.**

This is what OP's hack does.
- Make 7-inch display working.
- Make touch panel working.

# Install
ssh into your raspiberry

```
git clone https://github.com/akhepcat/waveshare-7inch-touchscreen-driver
cd waveshare-7inch-touchscreen-driver
chmod +x install.sh
sudo apt-get update
sudo ./install.sh
sudo restart
```

# How did OP hack it
By looking at the dmesg information, we can see it is installed as a hid-generic driver, the vendor is 0x0eef(eGalaxy) and product is 0x0005.
0x0005 can't be found anywhere, OP thinks the company wrote their own driver to support this.

## dmesg infomation
```
[    3.518144] usb 1-1.5: new full-speed USB device number 4 using dwc_otg
[    3.606036] udevd[174]: starting version 175
[    3.631476] usb 1-1.5: New USB device found, idVendor=0eef, idProduct=0005
[    3.641195] usb 1-1.5: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.653540] usb 1-1.5: Product: By ZH851
[    3.659956] usb 1-1.5: Manufacturer: RPI_TOUCH
[    3.659967] usb 1-1.5: SerialNumber: \xffffffc2\xffffff84\xffffff84\xffffffc2\xffffffa0\xffffffa0B54711U335
[    3.678577] hid-generic 0003:0EEF:0005.0001: hiddev0,hidraw0: USB HID v1.10 Device [RPI_TOUCH By ZH851] on usb-bcm2708_usb-1.5/input0
```
kernel config provide us more clue:
```
CONFIG_USB_EGALAX_YZH=y
```

It is really a eGalaxy based device. Google this config but found nothing.
OP doesn't have a eGalxy to compare, maybe waveshare's touchscreen is only modifed the product id.

Then OP looked at the response of hidraw driver:

## hidraw driver analysis
```
pi@raspberrypi ~/python $ sudo xxd -c 25 /dev/hidraw0
0000000: aa00 0000 0000 bb00 0000 0000 0000 0000 0000 0000 0000 0000 00  .........................
0000019: aa01 00c5 0134 bb01 0000 0000 0000 0000 0000 0000 0000 0000 cc  .....4...................
```

You can try by your self, by moving the figure on the screen you will notice the value changes.
Take one for example:
```
0000271: aa01 00e4 0139 bb01 01e0 0320 01e0 0320 01e0 0320 01e0 0320 cc  .....9..... ... ... ... .
```

"aa" is start of the command, "01" means clicked while "00" means unclicked. "00e4" and "0139" is the X,Y position (HEX).
"bb" is start of multi-touch, and the following bytes are the position of each point.

## Write the driver
OP used python to read from hidraw driver and then use uinput to emulate the mouse. It is quite easy to do. Please look at the source code.

## Other systems
OP thinks this driver can work in any linux system with hidraw and uinput driver support.


