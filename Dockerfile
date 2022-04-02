FROM python:3

ARG ssh_prv
ARG ssh_pub

ENV ssh_prv_key=$ssh_prv
ENV ssh_pub_key=$ssh_pub

RUN apt update -y\
 && apt dist-upgarde -qqy\
 && apt install python3-yaml python3-subprocess git openssh-server -qqy\
 && git clone https://github.com/joshuaboniface/rffmpeg.git

RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

WORKDIR /etc/rffmpeg

RUN rm LICENSE README.md \
 && cp rffmpeg.yml.sample rffmpeg.yml \
 && rm rffmpeg.yml.sample \
 && cp ./rffmpeg.py /usr/local/bin/rffmpeg.py \

RUN ln -s /usr/local/bin/rffmpeg.py /usr/local/bin/ffmpeg \
    && ln -s /usr/local/bin/rffmpeg.py /usr/local/bin/ffprobe