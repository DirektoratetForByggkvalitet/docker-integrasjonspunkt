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

ARG PORT=9093
ENV PORT=${PORT} SSH_PORT=2222 TZ="Europe/Oslo"
ADD integrasjonspunkt-local.properties /opt/integrasjonspunkt/integrasjonspunkt-local.properties
RUN mkdir -p /opt/integrasjonspunkt/activemq-data /opt/integrasjonspunkt/messages /opt/integrasjonspunkt/uploads && \
    chown -R java:java /opt/integrasjonspunkt


# Opprydding
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
EXPOSE 2222 9093
HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost:9093/manage/health || exit 1

ENTRYPOINT ["/init"]