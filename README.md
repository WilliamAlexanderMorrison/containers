# Introduction of my use-case

* I am attemping to force security for my home network by way of the controls available on my router. 
* I desire to prevent all external traffic in or out for most of my IoT devices. 
* I have a 'primary' Raspberry Pi as my  home automation device which is allowed to access the internet.
* I have a 'secondary' Raspberry Pi which is prevented from any internet access. 

The problem I discovered is that my secondary Raspberry Pi would lose time when it was powered down. This is due to the fact that Raspberry Pis do not have a hardward clock. As such, a [Raspbian package](https://manpages.debian.org/jessie/fake-hwclock/fake-hwclock.8.en.html) stores the last known time in a file.

In order to remedy the situation I wanted my 'primary' Pi to function as a NTP server that could feed the current time to my 'secondary' Pi. I forked [jcberthon's project](https://github.com/jcberthon/containers) which created a NTP service in a docker container. That version used somewhat complicated docker configurations  to have the container reach back into the device on which the container was hosted to serve as the time service. 

That was too complicated for my tastes, so I:
* Simplified the project to use docker-compose 
* Changed the configurations so that the NTP server only provides the time the clients without changing the device on which the container is hosted

## Step-by-Step Instructions to Configure the NTP server with Docker-Compose
* Install both Docker and Docker Compose following instructions in this [documentation](https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html)
* Create a directory with the docker and monitor configuration files in this repo by using the command `git clone https://github.com/WilliamAlexanderMorrison/rpi-ntp-server`
* Navigate into the rpi-ntp-server directory 
* Open the `ntp.conf.example` configuration file
  * Configure the pools
    * https://www.ntppool.org/en/ for a list of NTP pools
  * Configure any network restrictions for the server
    * http://support.ntp.org/bin/view/Support/AccessRestrictions
* Build the docker with the command `docker-compose build`
  * This will create a docker container with the rpi-ntp-server repo
* Start the docker container with the command `docker-compose up -d`
* Test that the server is providing the time when asked on another device
  * I did this on a Windows device with the portable Windows app discussed here: https://superuser.com/a/1380456

## Step-by-Step Instructions to Configure the Timedatectl package to reference your NTP server
* Follow the Timedatectl configuration section of this guide: https://raspberrytips.com/time-sync-raspberry-pi/
  * Open the Timedatectl configuration file
```sudo nano /etc/systemd/timesyncd.conf```
  * Uncomment out the NTP= line of the file
  * Append your NTP server's device's IP or hostname
    * I also configured a fallback NTP in case my server malfunctioned and I wanted to allow the device access to the internet to check the time
```
[Time]
NTP=192.168.1.118
FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org
```
* Follow the Enable or disable the time synchronization of this guide: https://raspberrytips.com/time-sync-raspberry-pi/
```sudo timedatectl set-ntp true```
* Reboot your Raspberry Pi
```sudo reboot```
* Test your device to ensure Timedatctl is working as expected as described in the Usage section of this guide: https://wiki.archlinux.org/index.php/systemd-timesyncd
```timedatectl timesync-status```