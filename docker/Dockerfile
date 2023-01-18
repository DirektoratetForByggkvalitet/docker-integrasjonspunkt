FROM digdir/integrasjonspunkt:latest

# Digdir opererer med USER java, overstyrer det
USER root

ENV TERM=xterm DEBIAN_FRONTEND=noninteractive
COPY --from=arpaulnet/s6-overlay-stage:2.0 / /

RUN apt-get update && apt-get install -yq openssh-server nano
ADD docker/sshd_config /etc/ssh/sshd_config
RUN echo "root:Docker!" | chpasswd 
ADD docker/services.d /etc/services.d

ARG PORT=80
ENV PORT=${PORT} SSH_PORT=2222 TZ="Europe/Oslo"
ADD integrasjonspunkt-local.properties /opt/integrasjonspunkt

# Opprydding
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
EXPOSE 2222 80
HEALTHCHECK &{["CMD-SHELL" "curl -s --fail http://localhost:${PORT}/manage/health > /dev/null || exit 1"] "0s" "0s" "0s" '\x00'}
ENTRYPOINT ["/init"]