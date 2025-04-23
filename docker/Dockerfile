FROM eclipse-temurin:21-jre-jammy
LABEL no.dibk.description="Docker-image for Digdir integrasjonspunkt, basert på eclipse-temurin"
LABEL no.dibk.author="Eirik Wulff <ew@dibk.no>"
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}
LABEL no.digdir.integrasjonspunkt.version="${APP_VERSION}"

ENV TERM=xterm DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq openssh-server nano ca-certificates curl openssl xz-utils

# Installerer s6-overlay - https://github.com/just-containers/s6-overlay
ARG S6_OVERLAY_VERSION="3.2.0.2"
ADD https://github.com/DirektoratetForByggkvalitet/s6-overlay-installer.git /s6-overlay-installer
RUN /s6-overlay-installer/s6_install.sh && rm -rf /s6-overlay-installer
ENTRYPOINT ["/init"]

# Oppsett for cacerts + oppretting av brukeren java
ARG APP_DIR=/app
ENV APP_DIR=${APP_DIR}
# Legger til sertifikate
ADD docker/trustcerts /tmp/trustcerts
RUN mkdir -p ${APP_DIR} && \
    echo "Importerer sertifikater til cacerts" && \
    rm /tmp/trustcerts/.gitignore && \
    for FILE in /tmp/trustcerts/*; do \
        keytool -import -noprompt -trustcacerts -alias "${FILE%.*}" -file "${FILE}" \
        -keystore ${JAVA_HOME}/lib/security/cacerts -storepass changeit; \
    done && \
    rm -rf /tmp/trustcerts

ADD ./app.jar ${APP_DIR}/app.jar

# Oppsett for openssh-server
ADD docker/sshd_config /etc/ssh/sshd_config
ADD docker/motd.sh /etc/profile.d/motd.sh
RUN update-ca-certificates && \
    echo "root:Docker!" | chpasswd
ADD docker/s6-rc.d /etc/s6-overlay/s6-rc.d
RUN chmod -R 644 /etc/s6-overlay/s6-rc.d/* && chmod -R a+rX /etc/s6-overlay/s6-rc.d/*

ARG SERVER_PORT=9093
ENV SERVER_PORT=${SERVER_PORT} SSH_PORT=2222 TZ="Europe/Oslo"
ADD integrasjonspunkt-local.properties ${APP_DIR}/integrasjonspunkt-local.properties
ARG KEYSTORE_FILE=auth.p12
ADD ${KEYSTORE_FILE} ${APP_DIR}/${KEYSTORE_FILE}

# Opprydding
RUN mkdir -p ${APP_DIR}/integrasjonspunkt-logs ${APP_DIR}/activemq-data && \
    chown -R www-data:www-data ${APP_DIR} && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "" > /etc/motd

EXPOSE ${SSH_PORT} ${SERVER_PORT}
# HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost:9093/manage/health || exit 1
WORKDIR ${APP_DIR}
ARG APP_ENV=production
ENV APP_ENV=${APP_ENV}
ENV SPRING_PROFILES_ACTIVE=${APP_ENV}
ARG JAVA_OPTS="-Xmx2g"
ENV JAVA_OPTS=${JAVA_OPTS}
