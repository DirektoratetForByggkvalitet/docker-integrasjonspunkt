FROM eclipse-temurin:8u352-b08-jre
LABEL no.dibk.description "Docker-image for Digdir integrasjonspunkt, basert på eclipse-temurin 8u352"
LABEL no.dibk.author "Eirik Wulff <ew@dibk.no>"

ENV TERM=xterm DEBIAN_FRONTEND=noninteractive
ARG APP_DIR=/opt/integrasjonspunkt
ARG profile=staging
ENV APP_ENV=${profile}

COPY --from=arpaulnet/s6-overlay-stage:2.0 / /
ENTRYPOINT ["/init"]
COPY --from=digdir/integrasjonspunkt:latest /opt/integrasjonspunkt/app.jar ${APP_DIR}/app.jar

RUN apt-get update && apt-get install -yq openssh-server nano ca-certificates curl openssl
ADD docker/sshd_config /etc/ssh/sshd_config
RUN update-ca-certificates && \
    echo "root:Docker!" | chpasswd
ADD docker/services.d /etc/services.d
ADD docker/motd /etc/motd

ENV APP_DIR=/opt/integrasjonspunkt CERTHOST=tt02.altinn.no CERTPORT=443 CAKEYSTOREFILE=${JAVA_HOME}/lib/security/cacerts CAKEYSTOREPASS=changeit
RUN openssl s_client -connect ${CERTHOST}:${CERTPORT} </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${HOST}.cert && \
    keytool -import -noprompt -trustcacerts -alias ${HOST} -file ${HOST}.cert \
        -keystorefile ${CAKEYSTOREFILE} -storepass ${CAKEYSTOREPASS} && \
    groupadd -o -g 1000 java && useradd -o -r -m -u 1000 -g 1000 java

ENV PORT=9093 SSH_PORT=2222 TZ="Europe/Oslo"
ADD integrasjonspunkt-local.properties ${APP_DIR}/integrasjonspunkt-local.properties
ARG KS_PASS
ARG KS_ALIAS=dibk
ADD auth.p12 ${APP_DIR}/auth.p12
# Konverterer sertifikatet til JKS
RUN keytool -importkeystore \
        -srckeystore ${APP_DIR}/auth.p12 \
        -srcstorepass ${KS_PASS} \
        -srcstoretype pkcs12 \
        -srcalias ${KS_ALIAS} \
        -deststoretype jks \
        -destkeystore ${APP_DIR}/auth.jks \
        -deststorepass ${KS_PASS} \
        -destalias ${KS_ALIAS}  && \
    chown -R java:java ${APP_DIR}

# Opprydding
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
EXPOSE 2222 9093
# HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost:9093/manage/health || exit 1

WORKDIR ${APP_DIR}
LABEL version "0.6"
