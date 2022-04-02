FROM python:3

ARG ssh_prv
ARG ssh_pub

ENV SSH_PRV_KEY="" \
    SSH_PUB_KEY=""

RUN apt update \
 && apt dist-upgrade -qqy \
 && apt install git openssh-server -qqy \
 && pip install pyyaml \
 && git clone https://github.com/joshuaboniface/rffmpeg.git /etc/rffmpeg

RUN useradd -b /var/lib jellyfin

WORKDIR /var/lib/jellyfin

RUN mkdir .ssh

RUN echo "$SSH_PRV_KEY" > .ssh/id_rsa
RUN echo "$SSH_PUB_KEY" > .ssh/id_rsa.pub
RUN chown -R jellyfin:jellyfin .ssh \
 && chmod 600 .ssh/id_rsa \
 && chmod 600 .ssh/id_rsa.pub

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