ts_mppt_60_raspberrypi_monitor
==============================

Monitoring and logging application for a Morningstar TS-MPPT-60 Solar Charge Controller using a RaspberryPi and Ethernet

This program uses the Ruby Modbus implmentation (http://rmodbus.flipback.net/p/about.html).  
This supports both Serial and TCP connections but since my TS-MPPT-60 has Ethernet I have opted for that.

A full description of all available information from the modbus is here: http://www.morningstarcorp.com/wp-content/uploads/2014/02/TSMPPT.APP_.Modbus.EN_.10.2.pdf

I'm ussing RRDTool (Round Robin Database) as a fast and simple data backend for this application.  It has native ruby
bindings.  I'll likely provide a simple Sinatra Web interface and server at some point.

TODO
====
* Test on the real system
* Provide web access to the RRD graphs

RaspberryPi setup:
==================
# Start with the current Raspberry Pi image like 2014-06-20-wheezy-raspbian

# Expand system image, reboot.
sudo raspi-config

# Set static ip 
sudo nano /etc/network/interfaces
::
iface eth0 inet static
address 192.168.1.150 # use your own IP schema
netmask 255.255.255.0
broadcast 192.168.1.255
gateway 192.168.1.1

# Update system:
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade

# Install rrdtool (for graphing)

sudo apt-get install librrd-dev

# Install RVM/ruby, this takes a long time:

curl -L get.rvm.io | bash -s stable --rails

#refresh the shell:
source /home/pi/.rvm/scripts/rvm

# Install ExecJS
gem install execjs

# Install NodeJS
sudo apt-get install nodejs

#Install RRD Tool
sudo apt-get install ruby-dev
sudo apt-get install rrdtool

# Install ruby gems (don’t use sudo here, each user account needs its own RVM gemset)
gem install rrd-ffi
gem install serialport
gem install rmodbus
