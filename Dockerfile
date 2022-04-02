FROM python:3

ENV DEBIAN_FRONTEND noninteractive

#ARG SSH_PRV
#ARG SSH_PUB

#ENV SSH_PRV_KEY=${SSH_PRV_KEY} \
#    SSH_PUB_KEY=${SSH_PUB}

RUN apt update \
 && apt dist-upgrade -qqy \
 && apt install git openssh-server ffmpeg -qqy \
 && pip install pyyaml \
 && git clone https://github.com/joshuaboniface/rffmpeg.git /etc/rffmpeg

RUN wget https://github.com/jellyfin/jellyfin-ffmpeg/releases/download/v4.4.1-4/jellyfin-ffmpeg_4.4.1-4-bullseye_amd64.deb \
 && dpkg -i jellyfin-ffmpeg_4.4.1-4-bullseye_amd64.deb

RUN useradd -m -b /var/lib/ jellyfin

RUN mkdir /var/log/jellyfin \
 && chown jellyfin:jellyfin /var/log/jellyfin

WORKDIR /var/lib/jellyfin

RUN mkdir .ssh

#RUN echo ${SSH_PRV_KEY} > .ssh/id_rsa \
# && echo ${SSH_PUB_KEY} > .ssh/id_rsa.pub \
# && chown -R jellyfin:jellyfin .ssh \
# && chmod 600 .ssh/id_rsa \
# && chmod 600 .ssh/id_rsa.pub

WORKDIR /etc/rffmpeg

RUN rm LICENSE README.md \
 && cp rffmpeg.yml.sample rffmpeg.yml \
 && rm rffmpeg.yml.sample \
 && cp ./rffmpeg.py /usr/local/bin/rffmpeg.py

RUN ln -s /usr/local/bin/rffmpeg.py /usr/local/bin/ffmpeg \
 && ln -s /usr/local/bin/rffmpeg.py /usr/local/bin/ffprobe

RUN service ssh start

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]