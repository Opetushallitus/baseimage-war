#!/bin/bash -e
#

BASEPATH="/root"
CONFIGPATH="/etc/oph-environment"
VARS="${CONFIGPATH}/opintopolku.yml"
CATALINA_BASE="/opt/tomcat/"
CERT="${CONFIGPATH}/cert/ssl.pem"
LOGPATH="${CONFIGPATH}/log"

echo "Downloading environment-specific properties"
env_config_path=${ENV_CONFIG_S3_PATH:-/services/}
env_config_version=${ENV_CONFIG_VERSION:-latest}
aws s3 cp s3://${ENV_BUCKET}${env_config_path}${env_config_version}/ ${CONFIGPATH}/ --recursive --exclude "templates/*"
cp -vr ${CONFIGPATH}/* ${BASEPATH}/oph-configuration/
cp -v ${LOGPATH}/logback-access.xml ${CATALINA_BASE}/conf/

echo "Overwriting with AWS-specific configs..."
for AWS_TEMPLATE in `find ${BASEPATH}/ -name "*.template.aws"`
do
  ORIGINAL_TEMPLATE=`echo ${AWS_TEMPLATE} | sed "s/\.aws//g"`
  cp -v ${AWS_TEMPLATE} ${ORIGINAL_TEMPLATE}
done

echo "Processing configuration files..."
for tpl in `find ${BASEPATH}/ -name "*.template"`
do
  target=`echo ${tpl} | sed "s/\.template//g"`
  echo "Prosessing ${tpl} -> ${target}"
  j2 ${tpl} ${VARS} > ${target}
  chmod 0755 ${target}
done

CACERTSPWD="`grep "java_cacerts_pwd" /etc/oph-environment/opintopolku.yml | grep -o -e '\".*\"' | sed 's/^\"\(.*\)\"$/\1/'`"
if [ -f "${CERT}" ]; then
  echo "Installing local certificates to Java..."
  openssl x509 -outform der -in ${CERT} -out /tmp/ssl.der
<<<<<<< HEAD
  keytool -import -noprompt -storepass ${CACERTSPWD} -alias opintopolku -keystore /usr/java/latest/jre/lib/security/cacerts -file /tmp/ssl
=======
  keytool -import -noprompt -storepass ${CACERTSPWD} -alias opintopolku -keystore /opt/java/openjdk/lib/security/cacerts -file /tmp/ssl
>>>>>>> PP-413: Add run script to baseimage
fi

export LC_CTYPE=fi_FI.UTF-8
export JAVA_TOOL_OPTIONS='-Dfile.encoding=UTF-8'
export JMX_PORT=1133
mkdir -p /root/logs
mkdir -p /root/tomcat
ln -s /root/logs/ /root/tomcat/logs

<<<<<<< HEAD
=======
# PP-299: This symlink is for backwards-compatibility and can be removed once no services use base-legacy image
if [ -f "/root/jmx_prometheus_javaagent-0.10.jar" ]; then
  echo "Found legacy jmx_exporter, symlinking it to a versionless name"
  ln -s /root/jmx_prometheus_javaagent-0.10.jar /root/jmx_prometheus_javaagent.jar
fi

>>>>>>> PP-413: Add run script to baseimage
echo "Starting Prometheus node_exporter..."
nohup /root/node_exporter > /root/node_exporter.log  2>&1 &

if [ ${DEBUG_ENABLED} == "true" ]; then
  echo "JDWP debugging enabled..."
<<<<<<< HEAD
  DEBUG_PARAMS=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1233"
else
  echo "JDWP debugging disabled..."
  DEBUG_PARAMS=""
fi

=======
  STANDALONE_DEBUG_PARAMS=" -Xdebug -Xrunjdwp:transport=dt_socket,address=1233,server=y,suspend=n"
  DEBUG_PARAMS=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1233"
else
  echo "JDWP debugging disabled..."
  STANDALONE_DEBUG_PARAMS=""
  DEBUG_PARAMS=""
fi

export HOME="/root"
export LOGS="${HOME}/logs"

>>>>>>> PP-413: Add run script to baseimage
echo "Using java options: ${JAVA_OPTS}"
echo "Using secret java options: ${SECRET_JAVA_OPTS}"

if [ `ls -l /opt/tomcat/webapps/ | wc -l` -ne 1 ]; then
    echo "Running tomcat war application..."
    echo "Creating setenv.sh..."
    cat > /opt/tomcat/bin/setenv.sh <<- SETENV
#!/bin/sh
JAVA_OPTS="$JAVA_OPTS
  ${SECRET_JAVA_OPTS}
  -Duser.home=/root
  -Dlog4j.debug=true
  -Djava.util.logging.config.file=${LOGPATH}/logging.properties
  -Djuli-logback.configurationFile=file://${LOGPATH}/logback-tomcat.xml
  -DHOSTNAME=`hostname`
  -Djava.net.preferIPv4Stack=true
  -Dfile.encoding=UTF-8
  -Djava.security.egd=file:/dev/urandom
  -Dcom.sun.management.jmxremote
  -Dcom.sun.management.jmxremote.authenticate=false
  -Dcom.sun.management.jmxremote.ssl=false
  -Dcom.sun.management.jmxremote.port=${JMX_PORT}
  -Dcom.sun.management.jmxremote.rmi.port=${JMX_PORT}
  -Dcom.sun.management.jmxremote.local.only=false
  -Djava.rmi.server.hostname=localhost
  -javaagent:/root/jmx_prometheus_javaagent.jar=1134:/root/prometheus.yaml
<<<<<<< HEAD
  -XX:+PrintGCDetails
  -XX:+PrintGCTimeStamps
  -Xloggc:/root/logs/tomcat_gc.log
  -XX:+UseGCLogFileRotation
  -XX:NumberOfGCLogFiles=10
  -XX:GCLogFileSize=10m
=======
  -Xlog:gc*:file=${LOGS}/${NAME}_gc.log:uptime:filecount=10,filesize=10m
>>>>>>> PP-413: Add run script to baseimage
  -XX:+HeapDumpOnOutOfMemoryError
  -XX:HeapDumpPath=/root/dumps/tomcat_heap_dump-`date +%Y-%m-%d-%H-%M-%S`.hprof
  -XX:ErrorFile=/root/logs/tomcat_hs_err.log
  ${DEBUG_PARAMS}
"
SETENV
    case ${NAME} in
      koski|sijoittelu-service|valinta|valintaperusteet-service|valintalaskenta|valintalaskentakoostepalvelu|dokumenttipalvelu|seuranta)
        echo "Skipped project's log4j.properties file."
        ;;
      *)
        echo "Using project's log4j.properties file."
        echo 'JAVA_OPTS="$JAVA_OPTS -Dlog4j.configuration=file:///root/oph-configuration/log4j.properties"' >> /opt/tomcat/bin/setenv.sh
        ;;
    esac

    echo "Create common.properties"
    case ${NAME} in
      valinta|valinta-ui|valintaperusteet-service|sijoittelu-service)
        cp -fv ${BASEPATH}/oph-configuration/valinta.properties ${BASEPATH}/oph-configuration/common.properties
        ;;
      koski)
        echo "...skipped!"
        ;;
      *)
        cp -fv ${BASEPATH}/oph-configuration/${NAME}.properties ${BASEPATH}/oph-configuration/common.properties
        ;;
    esac

    # PP-277: Override tomcat server.xml with custom version to increase thread limit
    case ${NAME} in
      valinta)
        if [ -f "/root/oph-configuration/valinta-tomcat-server.xml" ]; then
          echo "Overriding tomcat server.xml with custom version"
          cp -fv ${BASEPATH}/oph-configuration/valinta-tomcat-server.xml ${CATALINA_BASE}/conf/server.xml
        fi
        ;;
      *)
        echo "...skipped!"
        ;;
    esac

    echo "Create modified server.xml for eperusteet"
    case ${NAME} in
      eperusteet|eperusteet-amosaa|eperusteet-ylops|eperusteet-opintopolku)
        cat > /opt/tomcat/conf/server.xml <<- SERVERXML
<?xml version='1.0' encoding='utf-8'?>
<Server port="8005" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JasperListener" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <Service name="Catalina">

    <Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol" connectionTimeout="20000" secure="true" scheme="https"
               SSLEnabled="false" proxyPort="443" maxThreads="50" asyncTimeout="150000" URIEncoding="UTF-8"/>

    <!-- Define an AJP 1.3 Connector on port 8009 -->
    <Connector port="8009" protocol="AJP/1.3" maxThreads="1000" />

    <Engine name="Catalina" defaultHost="localhost">

      <Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="true">
        <Valve className="ch.qos.logback.access.tomcat.LogbackValve" filename="conf/logback-access.xml" asyncSupported="true"/>
      </Host>
    </Engine>
  </Service>
</Server>
SERVERXML
        ;;
      *)
        echo "...skipped, not eperusteet!"
        ;;
    esac

    CONTEXT="${BASEPATH}/tomcat/conf/context.xml"
    if [ -f ${CONTEXT} ]; then
      echo "Create context.conf"
      j2 ${CONTEXT} ${VARS} > ${CATALINA_BASE}/conf/context.xml || true
    fi

    if [ ${NAME} == "authentication" ]; then
      echo "Hax /data00/oph/${NAME}/ -directory"
      mkdir -p /data00/oph/
      ln -s /root/ /data00/oph/${NAME}
    fi

    echo "Starting application..."
    exec ${CATALINA_BASE}/bin/catalina.sh run
else
  echo "Fatal error: No war found, exiting!"
  exit 1
fi
