FROM adoptopenjdk/openjdk8:alpine-slim

RUN addgroup -S oph -g 1001 && adduser -u 1001 -S -G oph oph

COPY files/dump_threads.sh /root/bin/
COPY files/tomcat/server.xml /opt/tomcat/conf/
COPY --chown=oph:oph files/tomcat/ehcache.xml /home/oph/oph-configuration/
COPY files/tomcat/jars/*.jar /opt/tomcat/lib/
COPY files/run.sh /usr/local/bin/run

WORKDIR /root/
COPY *.sh ./
RUN \
  sh install.sh && \
  sh test.sh && \
  rm *.sh
