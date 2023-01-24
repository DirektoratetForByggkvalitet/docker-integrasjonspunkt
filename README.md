# LES MEG

Docker-image som kjører DiBK sitt integrasjonspunkt mot Digdir i Azure. 

Integrasjonspunktet kjører med støtte fra MySQL-database, og lagrer dermed ingenting lokalt.

Konfigurasjonsfilen befolkes fra Bitbucket Pipelines ved bygging. Samtidig hentes også virksomhetssertifikatet fra Azure Key Vault, og public key lagres til en pkcs12-fil.
## Innstillinger for App Service

- Settes opp som en Web App med Docker-konteiner fra **dibknoe.azurecr.io/app/integrasjonspunkt**
- Continous deployment slås på 
- **WEBSITES_PORT** må settes til 9093
- **WEBSITES_CONTAINER_START_TIME_LIMIT** bør settes til minst 300 sekunder (standard er 230 sekunder, maks er 1800). Dette for at konteineren skal ha tid til å starte opp. Normalt sett starter den dog opp på under 180 sekunder.
- Startup er automatisk, og trenger ingen innstillinger
- Health Check kan settes opp med URL /manage/health

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

### Miljøvariabler for integrasjonspunktet ###

| Variabelnavn | Beskrivelse | Standardverdi |
| ----- | ----- | ----- |
| APP_ENV | Miljøet appen skal knyttes seg mot | production |
| SERVER_PORT | Porten integrasjonspunktet skal benytte | 9093 |
| ORG_NR | Organisasjonsnummeret til DiBK (organisasjonen som eier virksomhetssertifikatet) | 974760223 |
| KEYSTORE_PATH | URL til keystore-fila som har virksomhetssertifikatet | file:auth.p12 |
| KEYSTORE_TYPE | Type keystore-fil | PKCS12 |
| KEYSTORE_ALIAS | Friendly-name eller alias til sertfikatet i keystore-fila | dibk |
| KEYSTORE_PASS | Passordet til keystore og sertifikat | |
| DPI_ENABLE | Slår på eller av funksjonaliteten Digital Post for Innbyggere (DigiPost o.l.) | false |
| DPE_ENABLE | Slår på eller av funksjonalitet mot eInnsyn | true |
| DPV_ENABLE | Slår på eller av funksjonalitet mot Digital Post til Virksomheter (via Altinn) | true |
| DPV_USERNAME | Brukernavn for DPV | dibk |
| DPV_PASSWORD | Passord for DPV | |
| AUTH_ENABLE | Slår på eller av autentisering av bruker | false |
| AUTH_USERNAME | Brukernavn for autentisering | |
| AUTH_PASSWORD | Passord for autentisering | |
| DB_URL | JDBC-URL for å koble til databasen som lagrer alle data | jdbc:mysql://flexmysql-dibk.mysql.database.azure.com/integrasjonspunkt?useSSL=true&sslMode=REQUIRED&serverTimezone=UTC |
| DB_USERNAME | Brukernavn for databasen | |
| DB_PASSWORD | Passord for databasen | |
| ALTINN_HOST | Navn på tjeneren som brukes til kommunikasjon med Altinn | tt02.altinn.no |

## Avhengigheter ##

1. Virksomhetssertfikatet for DiBK må ligge i Key Vault spesifisert med variabelen AZURE_KV_NAME, og sertifikatet må ha et navn som korresponderer med variabelen AZURE_KV_CERT_NAME.
2. CA-sertifikatene til BuyPass og/eller Commfides må være tilgjengelige, slik at de kan bli installerte i Java sin truststore. URL til disse er satt opp i [bitbucket-pipelines.yml](bitbucket-pipelines.yml), og må endres dersom de ikke lenger fungerer.
3. Tjenernavnet til Altinn sitt produksjonsmiljø (**tt02.altinn.no**) finnes som build-arg ALTINN_HOST i [Dockerfile](docker/Dockerfile). Dette brukes også til å legge tjenerens sertifikat inn i truststore. Dersom Altinn bytter navn på tjeneren kan man endre variabelen **ALTINN_HOST** i Repository-variablene