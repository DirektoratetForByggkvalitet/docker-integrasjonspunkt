FROM java:8-jdk
MAINTAINER Eirik Wulff <ew@dibk.no>

ARG ver="1.7.93"

ENV TERM=xterm TZ=Europe/Oslo DEBIAN_FRONTEND=noninteractive
ENV VERSION=$ver

# Timezone and locale
RUN apt-get update && apt-get install -yq --no-install-recommends locales curl nano && \
	echo 'nb_NO.UTF-8 UTF-8' >> /etc/locale.gen && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
	echo "Europe/Oslo" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive locales && \
	dpkg-reconfigure -f noninteractive tzdata && \
	echo 'LC_ALL="nb_NO.UTF-8"' > /etc/default/locale && \
	echo 'LANG="nb_NO.UTF-8"' >> /etc/default/locale && \
	echo 'LANGUAGE="nb_NO.UTF-8"' >> /etc/default/locale

# Download the jar from Difi
RUN mkdir -p /integrasjonspunkt && cd /integrasjonspunkt && \
	curl -Lo integrasjonspunkt.jar "https://beta-meldingsutveksling.difi.no/service/local/repositories/releases/content/no/difi/meldingsutveksling/integrasjonspunkt/$VERSION/integrasjonspunkt-$VERSION.jar"

# Cleanup
RUN apt-get -q -y clean && \
	rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* && \
	rm -rf /usr/share/man/?? /usr/share/man/??_*

# Install the Keystore and properties file (not in Git)
COPY auth.jks /integrasjonspunkt/
COPY integrasjonspunkt-local.properties /integrasjonspunkt/

EXPOSE 9094

WORKDIR /integrasjonspunkt
CMD ["java", "-Xmx1024m", "-jar", "integrasjonspunkt.jar", "--app.logger.enableSSL=false" ]


LABEL version="1.1"

LABEL vendor="Direktoratet for byggkvalitet / Norwegian Building Authority" \
	description="Installs integrasjonspunkt from Difi, in the setting of DiBK" \
	src="https://bitbucket.org/dibk/difi-integrasjonspunkt" \
	author="Eirik Wulff <ew@dibk.no>"

LABEL image.tag="dibkdocker.azurecr.io/difi/integrasjonspunkt:latest"
