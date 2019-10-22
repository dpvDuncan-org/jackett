# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}alpine

# see hooks/post_checkout
ARG ARCH
COPY .gitignore qemu-${ARCH}-static* /usr/bin/

# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}debian:stable-slim

# see hooks/post_checkout
ARG ARCH
COPY qemu-${ARCH}-static /usr/bin

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
    apt-get install -qq -y curl jq libicu63 && \
    mkdir -p /opt/jackett &&\
    JACKETT_RELEASE=$(curl -s "https://api.github.com/repos/Jackett/Jackett/releases" | \
            jq -r '.[0] | .tag_name') && \
    if [ "${ARCH}" == "arm" ] ; \
    then JACKETT_ARCH="LinuxARM32"; \
    elif [ "${ARCH}" == "aarch64" ] ; \
    then JACKETT_ARCH="LinuxARM64"; \
    elif [ "${ARCH}" == "amd64" ] ; \
    then JACKETT_ARCH="LinuxAMDx64"; \
    else "echo Unknown arch: ${ARCH}" && exit 1; \
    fi && \
    jackett_url=$(curl -s https://api.github.com/repos/Jackett/Jackett/releases/tags/"${JACKETT_RELEASE}" | \
                jq -r '.assets[].browser_download_url' | grep ${JACKETT_ARCH}) && \
    echo "Download ${jackett_url}" && \
    curl -s -o - -L "${jackett_url}" | tar xz -C /opt/jackett --strip-components=1 &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    chmod 777 /opt/jackett -R && \
    mkdir /config && \
    apt-get purge -qq curl jq && \
    apt-get autoremove -qq && \
    apt-get autoclean -qq

# ports and volumes
EXPOSE 9117
VOLUME /config

CMD ["/opt/jackett/jackett", "--NoUpdates"]
