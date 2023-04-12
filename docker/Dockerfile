FROM eclipse-temurin:20-jre-alpine
#FROM eclipse-temurin:8u352-b08-jre
LABEL no.dibk.description "Docker-image for Digdir integrasjonspunkt, basert på eclipse-temurin"
LABEL no.dibk.author "Eirik Wulff <ew@dibk.no>"

ENV TERM=xterm DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache curl tar openssl bash zsh git shadow xz openssh nano ca-certificates

# Installerer s6-overlay
ARG S6_OVERLAY_VERSION=3.1.4.2
ARG ARCH=x86_64
RUN curl -Lo /tmp/s6-overlay-noarch.tar.xz  https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    curl -Lo /tmp/s6-overlay-symlinks-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && \
    curl -Lo /tmp/s6-overlay-${ARCH}.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-${ARCH}.tar.xz && \
    curl -Lo /tmp/s6-overlay-symlinks-arch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz && \
    rm /tmp/*.tar.xz
ENTRYPOINT ["/init"]

# Oppsett for cacerts + oppretting av brukeren java
ARG APP_DIR=/opt/integrasjonspunkt
ARG ALTINN_HOST=altinn.no
ENV APP_DIR=${APP_DIR} CERTHOST=${ALTINN_HOST} CERTPORT=443 TRUSTSTOREFILE=${JAVA_HOME}/lib/security/cacerts TRUSTSTOREPASS=changeit
# Legger til CA-sertifikater fra BuyPass og Commfides
ADD docker/trustcerts /tmp/trustcerts
RUN mkdir -p ${APP_DIR} && \
    openssl s_client -connect ${CERTHOST}:${CERTPORT} < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${CERTHOST}.cert && \
    keytool -import -noprompt -trustcacerts -alias ${CERTHOST} -file ${CERTHOST}.cert \
        -keystore ${TRUSTSTOREFILE} -storepass ${TRUSTSTOREPASS} && \
    groupadd -o -g 1000 java && useradd -o -r -m -u 1000 -g 1000 java && \
    rm ${CERTHOST}.cert && \
    echo "Importerer CA-sertifikater fra BuyPass og Commfides til cacerts" && \
    for FILE in /tmp/trustcerts/*; do \
        keytool -import -noprompt -trustcacerts -alias "${FILE%.*}" -file "${FILE}" \
        -keystore ${TRUSTSTOREFILE} -storepass ${TRUSTSTOREPASS}; \
    done && \
    rm -rf /tmp/trustcerts

ARG APP_VERSION=2.15.0
ENV APP_VERSION=${APP_VERSION}
ARG MAVEN_REPO=https://repo1.maven.org/maven2/no/difi/meldingsutveksling/integrasjonspunkt
ADD ${MAVEN_REPO}/${APP_VERSION}/integrasjonspunkt-${APP_VERSION}.jar /opt/integrasjonspunkt/app.jar

# Oppsett for openssh-server
ADD docker/sshd_config /etc/ssh/sshd_config
ADD docker/motd.sh /etc/profile.d/motd.sh
RUN update-ca-certificates && \
    echo "root:Docker!" | chpasswd
ADD docker/s6-rc.d /etc/s6-overlay/s6-rc.d
RUN chmod -R 644 /etc/s6-overlay/s6-rc.d/* && chmod -R a+rX /etc/s6-overlay/s6-rc.d/*

ARG serverport=9093
ENV SERVER_PORT=${serverport} SSH_PORT=2222 TZ="Europe/Oslo"
ADD integrasjonspunkt-local.properties ${APP_DIR}/integrasjonspunkt-local.properties
ARG KS_PASS
ARG KS_ALIAS=dibk
ADD auth.p12 ${APP_DIR}/auth.p12

# Opprydding
RUN chown -R java:java ${APP_DIR} && ssh-keygen -A

EXPOSE 2222 9093
# HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost:9093/manage/health || exit 1
WORKDIR ${APP_DIR}
ARG profile=staging
ENV SPRING_PROFILES_ACTIVE=${profile}
ARG JAVA_OPTS="-Xmx2g"
ENV JAVA_OPTS=${JAVA_OPTS}
