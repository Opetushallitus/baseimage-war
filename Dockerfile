FROM alpine:latest

COPY files/dump_threads.sh /root/bin/

WORKDIR /root/
COPY *.sh ./
RUN \
  sh install.sh && \
  sh test.sh && \
  rm *.sh
