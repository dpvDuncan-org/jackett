# syntax=docker/dockerfile:1
ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}debian:stable-slim

ARG JACKETT_RELEASE
ARG JACKETT_ARCH
ARG JACKETT_URL

ENV JACKETT_RELEASE=${JACKETT_RELEASE}
ENV JACKETT_ARCH=${JACKETT_ARCH}
ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/config
ENV DEBIAN_FRONTEND=noninteractive

COPY scripts/start.sh /

RUN echo 'Dpkg::Use-Pty "0";' > /etc/apt/apt.conf.d/00usepty
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get update -qq
RUN apt-get dist-upgrade -qq
RUN apt-get autoremove -qq
RUN apt-get autoclean -qq
RUN apt-get install -qq -y curl libicu67
RUN mkdir -p /opt/jackett /config
RUN curl -k -s -o - -L "${JACKETT_URL}" | tar xz -C /opt/jackett --strip-components=1
RUN chmod -R 777 /opt/jackett /config /start.sh
RUN apt-get purge -qq curl
RUN apt-get autoremove -qq
RUN apt-get autoclean -qq

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# ports and volumes
EXPOSE 9117
VOLUME /config

CMD ["/start.sh"]
