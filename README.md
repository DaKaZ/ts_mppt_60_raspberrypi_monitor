ts_mppt_60_raspberrypi_monitor
==============================

Monitoring and logging application for a Morningstar TS-MPPT-60 Solar Charge Controller using a RaspberryPi and Ethernet

This program uses the Ruby Modbus implmentation (http://rmodbus.flipback.net/p/about.html).  
This supports both Serial and TCP connections but since my TS-MPPT-60 has Ethernet I have opted for that.

A full description of all available information from the modbus is here: http://www.morningstarcorp.com/wp-content/uploads/2014/02/TSMPPT.APP_.Modbus.EN_.10.2.pdf

Pay special attention to the scalers for some of the readings, this took me a while to understand correctly and I was definitely thankful to have access to LiveView to see if my ruby was returning what the web UI was showing :)

As of October 2018 - this is successfully working on my Morningstar TS-MPPT-60 (yeah!)

RaspberryPi setup:
==================
Start with the current raspbian image

Expand system image, reboot.
`sudo raspi-config`

Set static ip 
```
sudo nano /etc/dhcpcd.conf
```

Update system:
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
```

Install RVM/ruby, this takes a long time:
`curl -L get.rvm.io | bash -s stable --rails`

Refresh the shell:
`source /home/pi/.rvm/scripts/rvm`

Install ruby gems (don’t use sudo here, each user account needs its own RVM gemset)
```
gem install rrd-ffi
gem install serialport
gem install rmodbus
```
