FROM adoptopenjdk/openjdk8:alpine-slim

RUN addgroup -S oph -g 1001 && adduser -u 1001 -S -G oph oph

COPY files/dump_threads.sh /usr/local/bin/
COPY files/tomcat/server.xml /opt/tomcat/conf/
COPY files/tomcat/ehcache.xml /etc/oph/oph-configuration/
COPY files/tomcat/jars/*.jar /opt/tomcat/lib/
COPY files/run.sh /usr/local/bin/run

WORKDIR /root/
COPY *.sh ./
RUN \
  sh install.sh && \
  sh test.sh && \
  rm *.sh
