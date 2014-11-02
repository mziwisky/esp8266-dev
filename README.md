esp8622-dev
===========

A Vagrant-powered virtual machine providing an isolated development
environment for the [ESP8266](https://github.com/esp8266/esp8266-wiki) $5
dollar "Internet of Things" WiFi module.

## Getting started

1. Install [Vagrant](https://www.vagrantup.com/)
2. clone this project
3. `$ vagrant up`

NOTE: that last step takes a decent chunk of time (~30 minutes on my 2013
Macbook Pro), most of which is consumed by building the cross-compiler.

## TODO

- notes and/or helper script about setting up USB-serial devices
- add a hello-world (probs the AT example) and ensure esptool.py is in
there for it

## ESP8622 Resources

- https://github.com/esp8266/esp8266-wiki
- http://esp8266.com
- `#esp8622` on Freenode

