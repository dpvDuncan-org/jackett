FROM multiarch/qemu-user-static as qemu
ARG ARCH

RUN if [ ! -f /usr/bin/qemu-${ARCH}-static ] ; then touch /usr/bin/qemu-${ARCH}-static; fi

ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}debian:stable-slim

ARG ARCH

COPY --from=qemu /usr/bin/qemu-${ARCH}-static /usr/bin

ARG JACKETT_RELEASE
ARG JACKETT_ARCH
ARG JACKETT_URL

RUN echo "JACKETT_RELEASE=${JACKETT_RELEASE}" && \
    echo "JACKETT_ARCH=${JACKETT_ARCH}" && \
    echo "JACKETT_URL=${JACKETT_URL}" && \
    echo "ARCH=${ARCH}"

ENV JACKETT_RELEASE=${JACKETT_RELEASE}
ENV JACKETT_ARCH=${JACKETT_ARCH}
ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/config
ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'Dpkg::Use-Pty "0";' > /etc/apt/apt.conf.d/00usepty && \
    ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get update -qq && \
    apt-get upgrade -qq && \
    apt-get dist-upgrade -qq && \
    apt-get autoremove -qq && \
    apt-get autoclean -qq && \
    apt-get install -qq -y curl libicu63 && \
    mkdir -p /opt/jackett /config &&\
    echo "Download ${JACKETT_URL}" && \
    curl -k -s -o - -L "${JACKETT_URL}" | tar xz -C /opt/jackett --strip-components=1 &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    chmod 777 /opt/jackett -R && \
    apt-get purge -qq curl && \
    apt-get autoremove -qq && \
    apt-get autoclean -qq

# ports and volumes
EXPOSE 9117
VOLUME /config

CMD ["/opt/jackett/jackett", "--NoUpdates"]
