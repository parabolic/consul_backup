FROM alpine:3.5

LABEL maintainer "nvelkovski@gmail.com"
LABEL Description "A backup docker for consul"

ENV working_directory=/consul_backup
ENV backup_script=consul_backup.sh

RUN apk update
RUN mkdir -p /aws
RUN apk -Uuv add \
      groff \
      less \
      python \
      py-pip \
      curl
RUN pip install --upgrade pip
RUN pip install awscli
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

RUN mkdir $working_directory
COPY scripts/* $working_directory/
RUN chmod +x $working_directory/$backup_script

ENTRYPOINT [ "sh", "-c", "$working_directory/$backup_script", "> /dev/stdout"]
