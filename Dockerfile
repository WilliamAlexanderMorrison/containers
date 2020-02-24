FROM debian:stretch

RUN apt-get update && apt-get install -y \
	ntp 

RUN chgrp root /var/lib/ntp && chmod g+w /var/lib/ntp

WORKDIR /rpi-ntp-server
RUN mkdir config
VOLUME config

#EXPOSE 123/udp

#ENTRYPOINT ["/usr/sbin/ntpd"]