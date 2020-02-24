FROM debian:stretch

RUN apt-get update && apt-get install -y \
	ntp \
    git

RUN chgrp root /var/lib/ntp && chmod g+w /var/lib/ntp

#ADD https://api.github.com/repos/WilliamAlexanderMorrison/rpi-ntp-server/git/refs/heads/master version.json
#RUN git clone https://github.com/WilliamAlexanderMorrison/rpi-ntp-server.git
WORKDIR /rpi-ntp-server
RUN mkdir config
VOLUME config

#EXPOSE 123/udp

#ENTRYPOINT ["/usr/sbin/ntpd"]