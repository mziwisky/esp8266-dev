esp8622-dev
===========

A Vagrant-powered virtual machine providing an isolated development
environment for the [ESP8266](https://github.com/esp8266/esp8266-wiki) $5
dollar "Internet of Things" WiFi module.


## What you'll need

1. A way to communicate with the chip's 3.3V TTL serial interface. I've had
   success with a [cable from Adafruit](http://www.adafruit.com/product/954)
   that's based on the PL2303 USB-to-TTL module.

2. [VirtualBox](https://www.virtualbox.org/), a free open source virtualization
   package.

3. [Vagrant](https://www.vagrantup.com), a virtualization management package
   geared towards development environments.


## Let's Do This

0. Clone this repository.

1. If you'll be using a USB-to-TTL device like the Adafruit one I noted above,
   you'll need to edit the `Vagrantfile` to include your device's VendorId and
   ProductId. If you have the exact one I mentioned above, you may be fine with
   the existing configuration, but you may as well do this step too to be sure.
   It's an easy one.

   - Connect your device to your computer and from the command line, run
     `VBoxManage list usbhost`. The output should be a list of entries that
     look like this:

    $ VBoxManage list usbhost
    Host USB Devices:
    
    ...
    
    UUID:               738b44fd-2f57-49dd-a16a-e31a0e7fa46f
    VendorId:           0x067b (067B)
    ProductId:          0x2303 (2303)
    Revision:           3.0 (0300)
    Port:               1
    USB version/speed:  0/1
    Manufacturer:       Prolific Technology Inc.
    Product:            USB-Serial Controller
    Address:            p=0x2303;v=0x067b;s=0x0002653c8cdc2c52;l=0x14100000
    Current State:      Captured

   - Note the VendorId and ProductId. Set the `$vendor_id` and `$product_id`
     variables in `Vagrantfile` to those values. They must be strings of the
     hexadecimal representations.

2. In the console, run `vagrant up`. Note that this may take a decent chunk of
   time -- it was ~30 minutes on my 2013 Macbook Pro. Most of it is spent
   building the cross-compiler. Don't worry, it's a one-time cost.

3. That's it! Now you can `vagrant ssh` and start building your images!


## Sweet! ...now what?

Well, if you're brand new to Vagrant, skip down a couple of sections for a very brief primer, then come back.

Oh hi! Wecome back! Now, if I were you, first thing I'd do is make sure my
serial cable worked.  With it plugged in, `vagrant ssh` into the machine and
run `lsusb` to make sure it's in your list of devices. To see where it's
attached, run `dmesg` and somewhere near the bottom you should see something
like `usb 1-1: pl2303 converter now attached to ttyUSB0`. If not, you might try
unplugging it and plugging it back in, then running it again -- that way it'll
definitely be near the bottom of the log. If your device is attached anywhere
besides `/dev/ttyUSB0`, you'll need to adjust your scripts and Makefiles as
appropriate. No big deal.

`console.sh` is a tiny script to start a serial console on `/dev/ttyUSB0` at
115200 baud. Most ESPs seem to ship with their baud set to that. You may need
to change the device, of course, based on the output from `dmesg`. Now go ahead
and run that bad boy.

Plug your ESP8266 into your serial interface and tie its CH_PD and GPIO0 pins
HIGH. Pinouts, along with a ton of other info, can be found [on the esp8266
wiki](https://github.com/esp8266/esp8266-wiki/wiki/Hardware_versions). Now
power it on. You should see a bunch of garbage in your serial terminal,
followed by the word `READY`. Type `AS+RST` and hit Enter, and you should get
this back:

    AT+RST
    OK
    
    ets Jan  8 2013,rst cause:4, boot mode:(3,6)
    
    wdt reset
    load 0x40100000, len 24236, room 16
    tail 12
    chksum 0xb7
    ho 0 tail 12 room 4
    load 0x3ffe8000, len 3008, room 12
    tail 4
    chksum 0x2c
    load 0x3ffe8bc0, len 4816, room 4
    tail 12
    chksum 0x46
    csum 0x46
    
    ready

You're in business! Now the fun part -- you can either play around with [the AT
commands](http://www.electrodragon.com/w/Wi07c#AT_Commands), or kill the
console and go on to build...


## Sample project -- a fricken webserver

I've included a very awesome sample project from
[Sprite_tm](http://spritesmods.com/) -- an HTTP server dubbed
[esphttpd](http://www.esp8266.com/viewtopic.php?f=6&t=376). From inside the
virtual machine, `cd /vagrant/esphttpd && make` to build it. Then make sure
your chip is in firmware upload mode by tieing the CH_PD and GPIO2 pins HIGH
and the GPIO0 pin LOW. Power it on, and run `make flash`, followed by `make
htmlflash`.

NOTE 1: you may receive `Failed to leave flash mode` exceptions after each
flash. Don't worry, it's most likely a false alarm.

NOTE 2: It's generally a good idea to power cycle the chip between uploads.
`make flash` includes a `sleep 3` between two flashes to different areas of
memory, so you can use that delay to cycle.


## Vagrant tips, for the uninitiated

The project's root directory is mirrored to `/vagrant` on the virtual machine.

You can `sudo` from inside the machine without a password.

`vagrant ssh` - ssh into the machine

`vagrant halt` - shuts down the machine

`vagrant suspend` - puts the machine to sleep

`vagrant destroy` - removes every trace of the machine. NOTE: after a destroy,
the next `vagrant up` will have to reprovision the machine from scratch,
meaning it'll take a while.

`vagrant up` - spins up the machine, bringing it back up from `halt`,
`suspend`, or `destroy`


## ESP8622 Resources

- https://github.com/esp8266/esp8266-wiki - the wiki containing everything I
  needed to build this repo
- http://esp8266.com - a forum for people interested in hacking on the chip
- `#esp8622` on Freenode
- http://www.electrodragon.com/w/Wi07c - another nice wiki I found useful for
  exploring the AT commands


## A final note

esphttpd, along with all the other resources in this repo, was copied wholesale
from another place. In the case of esphttpd, that other place is [this git
repo](http://git.spritesserver.nl/esphttpd.git). I decided to do this rather
than make references to everything so that _this_ repo would remain a set of
tools that work together out of the box. I may change this practice in the
future.

