# Strict mode
set -eu

echo "Testing that required software is installed"
apk --version
aws --version
java -version
j2 --version
cat /etc/alpine-release

echo "Testing that baseimage has files expected by the application during run script"
ls -la /opt/tomcat/bin/catalina.sh
ls -la /opt/tomcat/conf/server.xml
ls -la /root/oph-configuration/ehcache.xml
ls -la /opt/tomcat/lib/log4j*
ls -la /opt/tomcat/lib/logback-*
ls -la /root/jmx_prometheus_javaagent.jar
ls -la /root/node_exporter

echo "File space usage"
du -d 2 -h /
