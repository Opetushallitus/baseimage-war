# Strict mode
set -eu

echo "Test that required software is installed"
apk --version
aws --version
java -version
j2 --version
cat /etc/alpine-release

echo "Test that baseimage has files expected by the application during run script"
ls -la /opt/tomcat/bin/catalina.sh
ls -la /opt/tomcat/conf/server.xml
ls -la /home/oph/oph-configuration/ehcache.xml
ls -la /opt/tomcat/lib/log4j*
ls -la /opt/tomcat/lib/logback-*
ls -la /usr/local/bin/jmx_prometheus_javaagent.jar
ls -la /usr/local/bin/node_exporter
ls -la /usr/local/bin/run
ls -la /usr/lib/libfontconfig.so
ls -la /usr/lib/libuuid.so.1
ls -la /usr/lib/libc.musl-x86_64.so.1

echo "Largest directories:"
du -d 3 -m /|sort -nr|head -n 20
