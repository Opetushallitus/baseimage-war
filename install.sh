# Strict mode
set -eu

echo "Installing dependencies"
apk update
apk --no-cache add \
  bash \
  bzip2 \
  ca-certificates \
  fontconfig \
  jq \
  openssh \
  openssl \
  python3 \
  py-jinja2 \
  ttf-dejavu \
  unzip \
  wget \
  zip

ln -s /usr/bin/python3 /usr/bin/python

echo "Kludging font libraries in place"
ln -s /usr/lib/libfontconfig.so.1 /usr/lib/libfontconfig.so && \
  ln -s /lib/libuuid.so.1 /usr/lib/libuuid.so.1 && \
  ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1

echo "Installing tools for downloading environment configuration during service run script"
pip3 install --upgrade pip
pip3 install \
  awscli \
  docker-py \
  j2cli \
  jinja2 \
  jinja2-cli \
  pyasn1 \
  six
rm -rf /root/.cache

echo "Downloading glibc for compiling locale definitions"
GLIBC_VERSION="2.30-r0"
wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk
wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk

echo "Installing glibc for compiling locale definitions"
apk add \
  glibc-${GLIBC_VERSION}.apk \
  glibc-bin-${GLIBC_VERSION}.apk \
  glibc-i18n-${GLIBC_VERSION}.apk
rm -v glibc-*.apk
/usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
/usr/glibc-compat/bin/localedef -i fi_FI -f UTF-8 fi_FI.UTF-8

echo "Creating cache directories for package managers"
mkdir /home/oph/.m2/
mkdir /home/oph/.ivy2/

echo "Installing Prometheus jmx_exporter"
JMX_EXPORTER_VERSION="0.12.0"
wget -q https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar
mv jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar jmx_prometheus_javaagent.jar
echo "6c7d195cb67a09517ec1469c214b3d8ab0030bdbaa9e2ee06a9995d7b03c707c  jmx_prometheus_javaagent.jar" |sha256sum -c
mv jmx_prometheus_javaagent.jar /usr/local/bin/

echo "Installing Prometheus node_exporter"
NODE_EXPORTER_VERSION="0.18.1"
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
echo "b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424  node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz" |sha256sum -c
tar -xvzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
rm node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64

echo "Init Prometheus config file"
echo "{}" > /etc/prometheus.yaml

echo "Installing Tomcat"
TOMCAT_DL_PREFIX="https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.88/bin"
TOMCAT_PACKAGE="apache-tomcat-7.0.88.tar.gz"
wget -c -q -P /tmp/ ${TOMCAT_DL_PREFIX}/${TOMCAT_PACKAGE}
echo "675abed4e71e95793f549a2077d891e28f2f8e3427aca180d2ff6607be8885be  /tmp/${TOMCAT_PACKAGE}" |sha256sum -c
mkdir -p /opt/tomcat
tar xf /tmp/${TOMCAT_PACKAGE} -C /opt/tomcat --strip-components=1
rm -rf /opt/tomcat/webapps/*
chown -R oph:oph /opt/tomcat

echo "Clearing temp directory"
ls -la /tmp/
rm -rf /tmp/*.tar.gz
rm -rf /tmp/hsperfdata_root

echo "Make run script executable"
chmod ug+x /usr/local/bin/run