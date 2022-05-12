FROM python:3

ENV DEBIAN_FRONTEND noninteractive

ARG S6_OVERLAY_VERSION=3.1.0.1

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

RUN apt update \
 && apt dist-upgrade -qqy \
 && apt install curl gnupg \
 && curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/jellyfin.gpg \
 && echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list \
 && apt update

RUN apt install git openssh-server jellyfin-ffmpeg5 -qqy \
 && pip install pyyaml \
 && git clone https://github.com/joshuaboniface/rffmpeg.git /etc/rffmpeg

WORKDIR /etc/rffmpeg

RUN rm LICENSE README.md \
 && cp rffmpeg.yml.sample rffmpeg.yml \
 && rm rffmpeg.yml.sample \
 && cp ./rffmpeg.py /usr/local/bin/rffmpeg.py

RUN ln -s /usr/local/bin/rffmpeg.py /usr/local/bin/ffmpeg \
 && ln -s /usr/local/bin/rffmpeg.py /usr/local/bin/ffprobe

RUN echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
RUN sed -i 's+UsePAM yes+UsePAM no+g' /etc/rffmpeg/rffmpeg.yml

RUN groupmod -g 1000 users && \
 useradd -u 911 -U -d /var/lib/jellyfin -s /bin/false -m jellyfin && \
 usermod -G users jellyfin && \
 usermod --shell /bin/bash jellyfin && \
  rm -rf \
    /tmp/*

EXPOSE 22

COPY /root /

ENTRYPOINT ["/init"]