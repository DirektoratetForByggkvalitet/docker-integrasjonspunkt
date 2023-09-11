# LES MEG

Docker-image som kjører DiBK sitt integrasjonspunkt mot Digdir i Azure. 

Idéen er at integrasjonspunktet kjører i docker, med en web app foran. På den måten kan man gjøre HTTPS-kryptering og IP-whitelisting **utenfor** selve integrasjonspunktet, og vi kan bruke Azure Virtual Network og NAT gateway til å sikre én utgående IP-adresse for integrasjonspunktet. Det gjør det enkelt å få tilgang til Altinn og andre formidlere som bruker IP-whitelisting.

Integrasjonspunktet kjører med støtte fra MySQL-database, og lagrer dermed ingenting lokalt.

Konfigurasjonsfilen befolkes fra Bitbucket Pipelines ved bygging. Samtidig hentes også virksomhetssertifikatet fra Azure Key Vault, og public key lagres til en pkcs12-fil.

I bruk vil tjenesten fungere som en vanlig web app i Azure, og man kan legge på custom domains, SSL og slikt som man selv vil. Man kan også legge på brukernavn og passord på selve integrasjonspunktet, se AUTH-variablene under.

Man kan bruke SSH-koblingen i Azure-portalen for å gå inn i integrasjonspunktets miljø. Bruk kommandoen "with-contenv bash" for å få tilgang til alle miljøvariabler i konteineren. Integrasjonspunktet kjører under stien "**$APP_DIR**", som standard er **/app/integrasjonspunkt**.

## Innstillinger for Web App

- Settes opp som en Web App med Docker-konteiner fra ACR, Github eller annen repo med dette imaget lagret
- Continous deployment slås på
- Slå på automatisk omdirigering til HTTPS og sett den til å bruke HTTP 2.0 (ikke påkrevd, men kjekt)
- **WEBSITES_PORT** må legges inn som miljøvariabel og settes til samme verdi som SERVER_PORT nedenfor (9093), eller kan også settes for å overstyre SERVER_PORT.
- **WEBSITES_CONTAINER_START_TIME_LIMIT** bør legges inn som miljøvriabel og settes til minst 300 sekunder (standard er 230 sekunder, maks er 1800). Dette for at konteineren skal ha tid til å starte opp. Normalt sett starter den dog opp på under 180 sekunder.
- Health Check kan settes opp mot URI **/manage/health**
- Startup er automatisk, og trenger ingen innstillinger
- Bruk innstillingene under Network til å sette opp hvilke IP-nett som skal kunne snakke med integrasjonspunktet. Dette er viktig for sikringen av integrasjonspunktet. Documaster støtter å koble seg til integrasjonspunktet med autentisering.

## Miljøvariabler ##

Litt om miljøvariablene i Bitbucket
- WV = Variabelen finnes i Workspace variables. Hvis WV ikke er nevnt finnes variabelen i Repository variables

| Variabelnavn | Beskrivelse | Standardverdi |
| ----------- | ----------- | ----------- |
| AZURE_KV_NAME | Navnet til Key Vault som inneholder virksomhetssertifikatet | dibk-kv-norway (WV) |
| DOCKER_REGISTRY | Privat docker repo | dibknoe.azurecr.io (WV)
| AZURE_SP_ID | ID til Service Principal med rettigheter til Docker-repo og Key Vault |  |
| AZURE_SP_SECRET | Passord til Service Principal | |
| AZURE_KV_CERT_NAME | Navnet på virksomhetssertifikatet i Key Vault | virksomhetssertifikat-auth |

### Miljøvariabler for integrasjonspunktet sine innstillinger ###

| Variabelnavn | Beskrivelse | Standardverdi |
| ----- | ----- | ----- |
| APP_ENV | Miljøet appen skal knyttes seg mot, production eller staging | production |
| SERVER_PORT | Porten integrasjonspunktet skal benytte. Siden integrasjonspunktet ikke kjører som root må dette være en ikke-priviligert port.  Kan overstyres av WEBSITES_PORT i Web App-oppsettet. Porten eksponeres aldri mot Internett når integrasjonspunktet kjøres som en Web App. | 9093 |
| ORG_NR | Organisasjonsnummeret til DiBK (organisasjonen som eier virksomhetssertifikatet) | 974760223 |
| KEYSTORE_PATH | URL til keystore-fila som har virksomhetssertifikatet | file:auth.p12 |
| KEYSTORE_TYPE | Type keystore-fil | PKCS12 |
| KEYSTORE_ALIAS | Friendly-name eller alias til sertfikatet i keystore-fila | dibk |
| KEYSTORE_PASS | Passordet som settes til keystore og sertifikat, blir satt under bygging | |
| AUTH_ENABLE | Slår på eller av autentisering av bruker | false |
| AUTH_USERNAME | Brukernavn for autentisering | |
| AUTH_PASSWORD | Passord for autentisering | |
| DB_URL | JDBC-URL for å koble til databasen som lagrer alle data | jdbc:mysql://flexmysql-dibk.mysql.database.azure.com/integrasjonspunkt?useSSL=true&sslMode=REQUIRED&serverTimezone=UTC |
| DB_USERNAME | Brukernavn for databasen | |
| DB_PASSWORD | Passord for databasen | |
| ALTINN_HOST | Navn på tjeneren som brukes til kommunikasjon med Altinn | altinn.no |
| DPI_ENABLE | Slår på eller av funksjonaliteten Digital Post for Innbyggere (DigiPost o.l.) | false |
| DPE_ENABLE | Slår på eller av funksjonalitet mot eInnsyn | true |
| DPV_ENABLE | Slår på eller av funksjonalitet mot Digital Post til Virksomheter (via Altinn) | true |
| DPV_USERNAME | Brukernavn for DPV | dibk |
| DPV_PASSWORD | Passord for DPV | |
| DPO_ENABLE | Slår på Altinn Digital Post for offentlige | false |
| DPO_USERNAME | Brukernavn fra Altinn | |
| DPO_PASSWORD | Brukernavn fra Altinn | |
| DPF_ENABLE | Slår på funksjonalitet mot SvarUt | false |
| SVARUT_USER | Bruker for å sende meldinger til SvarUt. Settes opp som avsendersystem i svarut.ks.no | |
| SVARUT_PASSWORD | Passord for sending av SvarUt-meldinger | |
| SVARINN_USER | Bruker for å motta meldinger fra SvarUt. Settes opp som mottakersystem i Svarut.ks.no | |
| SVARINN_PASSWORD | Passord for mottak av meldinger fra SvarUt |


## Avhengigheter ##

1. Virksomhetssertfikatet for DiBK må ligge i Key Vault spesifisert med variabelen AZURE_KV_NAME, og sertifikatet må ha et navn som korresponderer med variabelen AZURE_KV_CERT_NAME.
2. CA-sertifikatene til BuyPass og/eller Commfides må være tilgjengelige, slik at de kan bli installerte i Java sin truststore. URL til disse er satt opp i [bitbucket-pipelines.yml](bitbucket-pipelines.yml), og må endres dersom de ikke lenger fungerer.
3. Tjenernavnet til Altinn sitt produksjonsmiljø (**altinn.no**) finnes som build-arg ALTINN_HOST i [Dockerfile](docker/Dockerfile). Dette brukes også til å legge tjenerens sertifikat inn i truststore. Dersom Altinn bytter navn på tjeneren kan man endre variabelen **ALTINN_HOST** i Repository-variablene