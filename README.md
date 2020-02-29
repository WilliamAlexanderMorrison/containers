# Introduction of my use-case

* I am attemping to force security for my home network by way of the controls available on my router. 
* I desire to prevent all internet traffic in or out for most of my IoT devices. 
* I have a 'primary' Raspberry Pi as my  home automation device which **is** allowed to access the internet.
* I have a 'secondary' Raspberry Pi which is NOT allowed to access the internet. 

The problem I discovered is that a Raspberry Pi restricted from access to the internet loses time when it is powered down. This is due to the fact that Raspberry Pis do not have a hardware clock. As such, a [Raspbian package](https://manpages.debian.org/jessie/fake-hwclock/fake-hwclock.8.en.html) stores the last known time in a file.

In order to remedy the situation I wanted my 'primary' device to function as a Network Time Protocol server that could feed the current time to my 'secondary' device. I forked [jcberthon's project](https://github.com/jcberthon/containers) which creates a NTP service in a docker container. That version uses somewhat complicated docker configurations to allow the container to reach back into the device and modify its time services. 

That was too complicated for my tastes, so:
* I changed the configurations so that the NTP server only functions as a server
  * Clients can request time from the server
  * The container does not change its device's time configurations
* I simplified the project to use docker-compose 

## Step-by-Step Instructions to Configure the NTP server with Docker-Compose
* Install both Docker and Docker Compose following instructions in this [documentation](https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html)
* Create a directory with the docker and NTP server configuration files from this repo by using the command `git clone https://github.com/WilliamAlexanderMorrison/rpi-ntp-server`
* Navigate into the rpi-ntp-server directory 
* Open the `ntp.conf.example` configuration file
  * Configure the pools
    * https://www.ntppool.org/en/ for a list of NTP pools
  * Configure any network restrictions for the server
    * http://support.ntp.org/bin/view/Support/AccessRestrictions
* Build the docker with `docker-compose build`
  * This will create a docker container with the rpi-ntp-server repo
* Start the docker container with `docker-compose up -d`
* Test that the server is providing the time when asked on another device
  * I did this on a Windows device with a portable Windows app discussed here: https://superuser.com/a/1380456

## Step-by-Step Instructions to Configure the Timedatectl package to reference your NTP server
* Follow the Timedatectl configuration section of this guide: https://raspberrytips.com/time-sync-raspberry-pi/
  * Open the Timedatectl configuration file with `sudo nano /etc/systemd/timesyncd.conf`
  * Uncomment out the NTP= line of the file
  * Append your NTP server's device's IP or hostname
    * I also configured a fallback NTP in case my server malfunctioned and I wanted to allow the device access to the internet to check the time
```
[Time]
NTP=192.168.1.118
FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org
```
* Set the device to use time syncrhonization with `sudo timedatectl set-ntp true`
  * As described in the Enable or disable the time synchronization section of this guide: https://raspberrytips.com/time-sync-raspberry-pi/
* Reboot your Raspberry Pi with `sudo reboot`
* Test your device with `timedatectl timesync-status` to ensure Timedatctl is working as expected
  * As described in the Usage section of this guide: https://wiki.archlinux.org/index.php/systemd-timesyncd 
