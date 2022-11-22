ARG JITSI_REPO=jitsi
ARG BASE_TAG=unstable
FROM ${JITSI_REPO}/base-java:${BASE_TAG}

#ARG CHROME_RELEASE=latest
#ARG CHROMEDRIVER_MAJOR_RELEASE=latest
ARG CHROME_RELEASE=106.0.5249.61
ARG CHROMEDRIVER_MAJOR_RELEASE=106

ENV RCLONE_VER=1.56.2 \
    BUILD_DATE=20220325T013603 \
    ARCH=amd64 \
    SUBCMD="" \
    CONFIG="--config /config/rclone/rclone.conf" \
    PARAMS=""

LABEL build_version="Version:- ${RCLONE_VER} Build-date:- ${BUILD_DATE}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-dpkg-wrap apt-get update && \
    apt-dpkg-wrap apt-get install -y jibri pulseaudio socat dbus dbus-x11 rtkit procps unzip wget stunnel4 && \
    apt-cleanup && \
    [ "${CHROME_RELEASE}" = "latest" ] && \
	wget -qO - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmour /etc/apt/trusted.gpg.d/google.gpg && \
	echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
	apt-dpkg-wrap apt-get update && \
    apt-dpkg-wrap apt-get install -y google-chrome-stable && \
    apt-cleanup || \
    [ "${CHROME_RELEASE}" != "latest" ] && \
    curl -4so "/tmp/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" && \
    apt-dpkg-wrap apt-get update && \
    apt-dpkg-wrap apt-get install -y "/tmp/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" && \
    apt-cleanup || \
    [ "${CHROMEDRIVER_MAJOR_RELEASE}" = "latest" ] && \
    CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE)" || \
    CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_MAJOR_RELEASE})" && \
    curl -4Ls "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_RELEASE}/chromedriver_linux64.zip" \
    | zcat >> /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver && \
    chromedriver --version && \
    apt-dpkg-wrap apt-get update && \
    apt-dpkg-wrap apt-get install -y jitsi-upload-integrations jq pulseaudio-utils && \
    apt-cleanup

RUN curl -O https://downloads.rclone.org/v${RCLONE_VER}/rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    unzip rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    cd rclone-*-linux-${ARCH} && \
    cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    cd ../ && \
    rm -f rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    rm -r rclone-*-linux-${ARCH} && \
    # creating  required directories for pulse-audio and rclone
	mkdir -p /root/.config/pulse/  && \
	chown -R jibri:jibri /root/.config/pulse && \
    mkdir -p /home/jibri/.config/pulse && \
    mkdir -p /home/jibri/.config/rclone/ && \
    chown -R jibri:jibri /home/jibri/.config/

# copying pulse audio related files
COPY pulseaudio-config/ /etc/jitsi/jibri/

COPY rootfs/ /

COPY start-pulseaudio.sh /home/jibri/.config/pulse/
COPY daemon.conf /etc/pulse/	
COPY daemon.conf /root/.config/pulse/

RUN chmod +x /home/jibri/.config/pulse/start-pulseaudio.sh && \
    # configuring stunnel
    chmod 777 -R /home/ && \
    mkdir -p /etc/stunnel && \
    sed -i -e 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

COPY stunnel.conf /etc/stunnel/stunnel.conf
COPY startstunnel /usr/bin/startstunnel

RUN chmod +x /usr/bin/startstunnel && \
    mkdir -p /opt/util/

COPY ffmpeg /opt/util/ffmpeg

# ffmpeg3 is the original ffmpeg
RUN mv /usr/bin/ffmpeg /usr/bin/ffmpeg2 && \
    ln -s /opt/util/ffmpeg /usr/bin/ffmpeg && \
    chmod +x /usr/bin/ffmpeg

VOLUME /config
