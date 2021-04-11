ARG JITSI_REPO=prayagsingh
FROM ${JITSI_REPO}/base-java

#ARG CHROME_RELEASE=latest
#ARG CHROMEDRIVER_MAJOR_RELEASE=latest
ARG CHROME_RELEASE=78.0.3904.97
ARG CHROMEDRIVER_MAJOR_RELEASE=78

ENV RCLONE_VER=1.55.0 \
    BUILD_DATE=20210405T131603 \
    ARCH=amd64 \
    SUBCMD="" \
    CONFIG="--config /config/rclone/rclone.conf" \
    PARAMS=""

LABEL build_version="Version:- ${RCLONE_VER} Build-date:- ${BUILD_DATE}"

LABEL Prayag Singh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
        apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y jibri pulseaudio socat dbus dbus-x11 rtkit libgl1-mesa-dri procps unzip wget stunnel4 \
        && apt-cleanup

RUN \
	[ "${CHROME_RELEASE}" = "latest" ] \
	&& wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O /etc/apt/trusted.gpg.d/google.asc \
	&& echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-dpkg-wrap apt-get update \
	&& apt-dpkg-wrap apt-get install -y google-chrome-stable \
	&& apt-cleanup \
	|| true

RUN \
        [ "${CHROME_RELEASE}" != "latest" ] \
        && curl -4so "/tmp/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" \
        && apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y "/tmp/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" \
        && apt-cleanup \
        || true

RUN \
        [ "${CHROMEDRIVER_MAJOR_RELEASE}" = "latest" ] \
        && CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE)" \
        || CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_MAJOR_RELEASE})" \
        && curl -4Ls "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_RELEASE}/chromedriver_linux64.zip" \
        | zcat >> /usr/bin/chromedriver \
        && chmod +x /usr/bin/chromedriver \
        && chromedriver --version

RUN \
        apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y jitsi-upload-integrations jq \
        && apt-cleanup

RUN apt-dpkg-wrap apt-get -y install pulseaudio-utils

RUN	mkdir -p /root/.config/pulse/  && \	
	chown -R jibri:jibri /root/.config/pulse && \
        mkdir -p /home/jibri/.config/pulse && \
        chown -R jibri:jibri /home/jibri/.config/pulse 

RUN curl -O https://downloads.rclone.org/v${RCLONE_VER}/rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    unzip rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    cd rclone-*-linux-${ARCH} && \
    cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    cd ../ && \
    rm -f rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    rm -r rclone-*-linux-${ARCH}


RUN mkdir -p /home/jibri/.config/rclone/ && \
    chown -R jibri:jibri /home/jibri/.config/rclone 

# copying pulse audio related files
COPY pjsua.config /etc/jitsi/jibri/
COPY icewm.preferences /etc/jitsi/jibri/
COPY asoundrc /etc/jitsi/jibri/

COPY rootfs/ /

COPY start-pulseaudio.sh /home/jibri/.config/pulse/
COPY daemon.conf /etc/pulse/	
COPY daemon.conf /root/.config/pulse/

RUN chmod +x /home/jibri/.config/pulse/start-pulseaudio.sh

RUN chmod 777 -R /home/ && \
    mkdir -p /etc/stunnel && \
    sed -i -e 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

COPY stunnel.conf /etc/stunnel/stunnel.conf
COPY startstunnel /usr/bin/startstunnel

RUN chmod +x /usr/bin/startstunnel && \
    mkdir -p /opt/util/

COPY ffmpeg /opt/util/ffmpeg
#COPY ffmpeg2 /opt/util/ffmpeg2

# ffmpeg3 is the original ffmpeg
RUN mv /usr/bin/ffmpeg /usr/bin/ffmpeg3 && \
    ln -s /opt/util/ffmpeg /usr/bin/ffmpeg && \
    chmod +x /usr/bin/ffmpeg
#    ln -s /opt/util/ffmpeg2 /usr/bin/ffmpeg2 && \
#    chmod +x /usr/bin/ffmpeg2

# changing /home/jibri permission because of pulseaudio. we can not run pulseaudio daemon with jibri user without changing permission
RUN chown -R jibri:jibri /home/jibri

VOLUME /config
