FROM adoptopenjdk/openjdk8:alpine-slim
<<<<<<< HEAD

ARG DL_PATH_TOKEN
=======
>>>>>>> d03ebc3a09592eba2499d5308ebff6c1c5b017df

COPY files/dump_threads.sh /root/bin/
COPY files/tomcat/ /tmp/tomcat-config/
COPY files/run.sh /tmp/scripts/run

WORKDIR /root/
COPY *.sh ./
RUN \
  sh install.sh && \
  sh test.sh && \
  rm *.sh
