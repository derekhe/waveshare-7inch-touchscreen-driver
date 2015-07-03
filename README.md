WaveShare 7-inch user space driver
===================================
I brought a [WaveShare 7-inch HDMI LCD](http://www.waveshare.net/shop/7inch-HDMI-LCD-B.htm) and it provides a USB touchscreen.
But the company only provide binary driver and images, which is quite bad. Installing binary driver will break self compiled kernel, and you can't get updated kernels.
I asked the company to provide the source code but they refused. They said they won't provide any source code because other companies can copy very fast so that their products can't sell out at good price.

OK. If they company won't want to provide anything, that's fine. I finally find out we can still drive the touchscreen by writing a user space driver.

Tested using official image: 2015-05-05-raspbian-wheezy.img

# Install
ssh into your raspiberry

clone this repo into any dir,then

```
chmod +x install.sh
./install.sh

sudo restart
```

# How do I hack it
By looking at the dmesg information, we can see it is installed as a hid-generic driver, the vendor is 0x0eef(eGalaxy) and product is 0x0005.
0x0005 can't be found anywhere, I think the company wrote their own driver to support this.

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

It is really a eGalaxy based device. Google this config but found nothing. I don't have a eGalxy to compare, maybe waveshare's touchscreen is only modifed the product id.

Then I look at the response of hidraw driver:

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
I use python to read from hidraw driver and then use uinput to emulate the mouse. It is quite easy to do. Please look at the source code.

## Other systems
I think this driver can work in any linux system with hidraw and uinput driver support.

## Calibration and Multitouch
Please try this driver and if you need to support multitouch and calibration, please [contact me](derekhe@april1985.com) to get the pro version.

## Other displays
I received an email from Adam, this driver may work with another type of screen:

> Hi there. Wanted to say thank you for writing and sharing the user space driver for 7" USB touchscreen, you have saved me!

> Mine is branded Eleduino (see here for details: http://www.eleduino.com/5-Inch-HDMI-Input-Touch-Screen-for-Raspberry-PI-2-B-B-and-Banana-pro-pi-p10440.html) and I had exactly the same issue - closed source binary driver which simply replaced kernel modules.

> Your solution worked out of the box, and didn't even need calibration.

> You're a hero!
