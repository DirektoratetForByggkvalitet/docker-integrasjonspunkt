FROM eclipse-temurin:19-jre-focal
LABEL no.dibk.description "Docker-image for Digdir integrasjonspunkt, basert på eclipse-temurin"
LABEL no.dibk.author "Eirik Wulff <ew@dibk.no>"

ENV TERM=xterm DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq openssh-server nano ca-certificates curl openssl xz-utils

# Installerer s6-overlay - https://github.com/just-containers/s6-overlay
ARG S6_OVERLAY_VERSION="3.1.4.2"
ARG TARGETARCH
ADD s6_install.sh /
RUN echo "Arkitektur: ${TARGETARCH}" && /s6_install.sh
ENTRYPOINT ["/init"]

# Oppsett for cacerts + oppretting av brukeren java
ARG APP_DIR=/app/integrasjonspunkt
ARG ALTINN_HOST=altinn.no
ENV APP_DIR=${APP_DIR} CERTHOST=${ALTINN_HOST} CERTPORT=443 TRUSTSTOREFILE=${JAVA_HOME}/lib/security/cacerts TRUSTSTOREPASS=changeit
# Legger til CA-sertifikater fra BuyPass og Commfides
ADD docker/trustcerts /tmp/trustcerts
RUN mkdir -p ${APP_DIR} && \
    openssl s_client -connect ${CERTHOST}:${CERTPORT} < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${CERTHOST}.cert && \
    keytool -import -noprompt -trustcacerts -alias ${CERTHOST} -file ${CERTHOST}.cert \
        -keystore ${TRUSTSTOREFILE} -storepass ${TRUSTSTOREPASS} && \
    groupadd -o -g 888 java && useradd -o -r -m -u 888 -g 888 java && \
    rm ${CERTHOST}.cert && \
    echo "Importerer CA-sertifikater fra BuyPass og Commfides til cacerts" && \
    for FILE in /tmp/trustcerts/*; do \
        keytool -import -noprompt -trustcacerts -alias "${FILE%.*}" -file "${FILE}" \
        -keystore ${TRUSTSTOREFILE} -storepass ${TRUSTSTOREPASS}; \
    done && \
    rm -rf /tmp/trustcerts

ARG APP_VERSION=2.16.0
ENV APP_VERSION=${APP_VERSION}
ARG MAVEN_REPO=https://repo1.maven.org/maven2/no/difi/meldingsutveksling/integrasjonspunkt
RUN curl -Lo ${APP_DIR}/app.jar ${MAVEN_REPO}/${APP_VERSION}/integrasjonspunkt-${APP_VERSION}.jar 

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
ARG KS_PASS
ARG KS_ALIAS=dibk
ADD auth.p12 ${APP_DIR}/auth.p12

# Opprydding
RUN chown -R java:java ${APP_DIR} && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "" > /etc/motd

EXPOSE 2222 ${SERVER_PORT}
# HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost:9093/manage/health || exit 1
WORKDIR ${APP_DIR}
ARG profile=staging
ENV SPRING_PROFILES_ACTIVE=${profile}
ARG JAVA_OPTS="-Xmx2g"
ENV JAVA_OPTS=${JAVA_OPTS}
