FROM digdir/integrasjonspunkt:latest

# Digdir opererer med USER java, overstyrer det
USER root

ENV TERM=xterm DEBIAN_FRONTEND=noninteractive
COPY --from=arpaulnet/s6-overlay-stage:2.0 / /

RUN apt-get update && apt-get install -yq openssh-server nano
ADD docker/sshd_config /etc/ssh/sshd_config
RUN echo "root:Docker!" | chpasswd 
ADD docker/services.d /etc/services.d
ADD docker/motd /etc/motd

ENV PORT=9093 SSH_PORT=2222 TZ="Europe/Oslo"
ADD integrasjonspunkt-local.properties /opt/integrasjonspunkt/integrasjonspunkt-local.properties
ADD auth.pkcs12 /opt/integrasjonspunkt/auth.pkcs12
RUN chown -R java:java /opt/integrasjonspunkt

# Opprydding
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
EXPOSE 2222 9093
HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost:9093/manage/health || exit 1

ARG profile=staging
ENV APP_ENV=${profile}

ENTRYPOINT ["/init"]