# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}alpine

# see hooks/post_checkout
ARG ARCH
COPY .gitignore qemu-${ARCH}-static* /usr/bin/

# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}alpine

# see hooks/post_checkout
ARG ARCH
COPY qemu-${ARCH}-static /usr/bin

RUN apk update && apk upgrade

ENV XDG_CONFIG_HOME=/config
ENV JACKETT_CMD=/opt/jackett/jackett

RUN apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
    apk add --no-cache libcurl ca-certificates && \
    apk add --no-cache --virtual=.build-dependencies curl jq && \
    mkdir -p /opt/jackett &&\
    JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases" | \
            jq -r '.[0] | .tag_name') && \
    case $ARCH in \
	    arm) \
		    JACKETT_ARCH="LinuxARM32" \
            break \
		    ;; \
	    aarch64) \
    		JACKETT_ARCH="LinuxARM64" \
		    break \
		    ;; \
	    amd64) \
    		JACKETT_ARCH="LinuxAMDx64" \
            break \
		    ;; \
        *) \
            JACKETT_ARCH="Mono" &&\
            export JACKETT_CMD="mono /opt/jackett/JackettConsole.exe" \
            ;; \
    esac &&\
    jackett_url=$(curl -s https://api.github.com/repos/Jackett/Jackett/releases/tags/"${Jackett_RELEASE}" | \
            jq -r '.assets[].browser_download_url' | grep ${JACKETT_ARCH}) && \
    curl -o /tmp/jackett.tar.gz -L "${jackett_url}" &&\
    tar xf /tmp/jackett.tar.gz -C /opt/jackett --strip-components=1 &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    chmod 777 /opt/jackett -R && \
    apk del .build-dependencies

# ports and volumes
EXPOSE 9117
VOLUME /config

CMD ["${JACKETT_BINARY}"]