FROM python:3

ARG ssh_prv
ARG ssh_pub

ENV ssh_prv_key=$ssh_prv
ENV ssh_pub_key=$ssh_pub

RUN apt update \
 && apt dist-upgrade -qqy \
 && apt install git openssh-server -qqy \
 && pip install pyyaml \
 && git clone https://github.com/joshuaboniface/rffmpeg.git /etc/rffmpeg

RUN useradd -b /var/lib jellyfin

WORKDIR /var/lib/jellyfin

RUN mkdir .ssh \
 && chown jellyfin .ssh

RUN echo "$ssh_prv_key" > .ssh/id_rsa \
 && echo "$ssh_pub_key" > .ssh/id_rsa.pub \
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