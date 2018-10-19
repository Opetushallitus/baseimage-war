FROM alpine:latest

COPY files/dump_threads.sh /root/bin/
COPY files/tomcat/ehcache.xml /root/oph-configuration/
COPY files/tomcat/server.xml /opt/tomcat/conf/
COPY files/tomcat/jars/ /opt/tomcat/lib/

WORKDIR /root/
COPY *.sh ./
RUN \
  sh install.sh && \
  sh test.sh && \
  rm *.sh
