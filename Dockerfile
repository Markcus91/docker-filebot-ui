FROM hurricane/dockergui:x11rdp1.2
#FROM hurricane/dockergui:x11rdp
#FROM hurricane/dockergui:xvnc

MAINTAINER David Coppit <david@coppit.org>

# User/Group Id gui app will be executed as
ENV USER_ID=99
ENV GROUP_ID=100

ENV APP_NAME="Filebot"

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive

# Speed up APT
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
  && echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

# Remove built-in Java 7
RUN apt-get purge -y openjdk-\* icedtea\*

# Auto-accept Oracle JDK license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# Filebot needs Java 8
RUN add-apt-repository ppa:webupd8team/java \
  && apt-get update \
  && apt-get install -y oracle-java8-installer \
  && apt-get clean

COPY filebot_4.6_amd64.deb /root/filebot.deb

RUN set -x \
  && dpkg -i /root/filebot.deb && rm /root/filebot.deb \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Otherwise RDP rendering of the UI doesn't work right.
RUN sed -i 's/java /java -Dsun.java2d.xrender=false /' /usr/bin/filebot

# Default resolution
ENV WIDTH=1280
ENV HEIGHT=720

COPY startapp.sh /startapp.sh

VOLUME ["/input", "/output"]