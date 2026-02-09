ARG APP_VERSION=v4.0.0
FROM ghcr.io/felleslosninger/efm-integrasjonspunkt:${APP_VERSION}
LABEL no.dibk.description="Docker-image for Digdir integrasjonspunkt, basert på Digdir sitt eget image"
LABEL no.dibk.author="Eirik Wulff <ew@dibk.no>"
ENV APP_VERSION=${APP_VERSION}
LABEL no.digdir.integrasjonspunkt.version="${APP_VERSION}"

RUN mkdir -p /logstash
ADD https://github.com/felleslosninger/efm-integrasjonspunkt/raw/refs/heads/main/integrasjonspunkt/src/main/resources/logstash/client.p12 /logstash/
ADD https://github.com/felleslosninger/efm-integrasjonspunkt/raw/refs/heads/main/integrasjonspunkt/src/main/resources/logstash/truststore.jks /logstash/
