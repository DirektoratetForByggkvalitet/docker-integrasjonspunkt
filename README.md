# LES MEG

Docker-image som kjører DiBK sitt integrasjonspunkt mot Digdir i Azure. 

Idéen er at integrasjonspunktet kjører i docker, med en web app foran. På den måten kan man gjøre HTTPS-kryptering og IP-whitelisting **utenfor** selve integrasjonspunktet, og vi kan bruke Azure Virtual Network og NAT gateway til å sikre én utgående IP-adresse for integrasjonspunktet. Det gjør det enkelt å få tilgang til Altinn og andre formidlere som bruker IP-whitelisting.

Integrasjonspunktet er satt opp til å kjøre med støtte fra MySQL-database, og lagrer dermed ingenting (viktig) lokalt.

Konfigurasjonsfilen befolkes fra Github Actions ved bygging. Samtidig hentes også virksomhetssertifikatet fra Azure Key Vault, og lagres til en pkcs12-fil.

I bruk vil tjenesten fungere som en vanlig web app i Azure, og man kan legge på custom domains, SSL og slikt som man selv vil. Man kan også legge på brukernavn og passord på selve integrasjonspunktet, se AUTH-variablene under.

Man kan bruke SSH-koblingen i Azure-portalen for å gå inn i integrasjonspunktets miljø. Bruk kommandoen "with-contenv bash" for å få tilgang til alle miljøvariabler i konteineren. Integrasjonspunktet kjører under stien "**$APP_DIR**", som standard er **/app**.

## Innstillinger for Azure Web App

- Settes opp som en Web App med Github Actions-publisering fra din fork av dette repoet. Azure vil legge til en action for å bygge og rulle ut imaget, men det vil ikke fungere uten videre. Du kan bruke [build-and-deploy.yml](.github/workflows/build-and-deploy.yml) som utgangspunkt til å sette opp dette, men du må legge til dine egne miljøvariabler for å knytte den til din Web App.
- Slå på automatisk omdirigering til HTTPS og sett den til å bruke HTTP 2.0 (ikke påkrevd, men kjekt)
- **WEBSITES_PORT** må legges inn som miljøvariabel og settes til samme verdi som SERVER_PORT nedenfor (9093), eller kan også settes for å overstyre SERVER_PORT.
- **WEBSITES_CONTAINER_START_TIME_LIMIT** bør legges inn som miljøvriabel og settes til minst 300 sekunder (standard er 230 sekunder, maks er 1800). Dette for at konteineren skal ha tid til å starte opp. Normalt sett starter den dog opp på under 180 sekunder.
- Health Check kan settes opp mot URI **/manage/health**. NB! Hvis du bruker AUTH vil det ikke fungere.
- Oppstart er automatisk, og trenger ingen innstillinger
- Bruk innstillingene under Network til å sette opp hvilke IP-nett som skal kunne snakke med integrasjonspunktet. Dette er **viktig for sikringen av integrasjonspunktet**. Documaster støtter å koble seg til integrasjonspunktet med basic-autentisering, men ikke alle arkivsystemer klarer det.

## Variabler og hemmeligheter ##

For å kjøre bygging og utrulling med Github Actions må det en del variabler og hemmeligheter til. Dette er ikke så lett å forklare enkelt, så vi oppfordrer til å titte litt på den arbeidsflyten vi har laget for å se sammenhengene. Det vi lister opp under kan også avvike litt fra de faktiske forholdene.

| Variabelnavn | Beskrivelse | Standardverdi |
| ----------- | ----------- | ----------- |
| KEYVAULT_NAME | Navnet til Key Vault som inneholder virksomhetssertifikatet | dibk-kv-norway (WV) |
| AZURE_KV_CERT_NAME | Navnet på virksomhetssertifikatet i Key Vault | virksomhetssertifikat-auth |
| ACR | Privat Azure Container Registry for å lagre image. Konteineren inneholder tross alt en god del virksomhets-private data… | dibknoe.azurecr.io |
| AZURE_SP_ID | ID til Service Principal med rettigheter til Docker-repo og Key Vault | |
| AZURE_TENANT_ID | ID til Azure-tenant som 'eier' Service Principal. Kan settes som xxxx-xxx-xxx-xxx-xxxxxxx eller firmanavn.onmicrosoft.com | |
| AZURE_SP_CERT | Action Secret som inneholder sertifikat for innlogging som Service Principal | |
| MACOS_KC_PASS | Brukes for å låse opp nøkkelringen til aktiv bruker når Action kjøres på self-hosted macOS. Det anbefales sterkt å bygge imaget på macOS, siden Apple Silicon bygger multiplattform ekstremt mye raskere | |

### Miljøvariabler for integrasjonspunktet sine innstillinger ###

Vi bruker et step som kjører envsubst for å befolke innstillingsfila til integrasjonspunktet. Dette kan også løses ved å endre konfig-steppet til å legge innholdet fra én variabel/secret inn som integrasjonspunkt-local.properties. Se [integrasjonspunkt-local.properties.dist](integrasjonspunkt-local.properties.dist) for inspirasjon.

| Variabelnavn | Beskrivelse | Standardverdi |
| ----- | ----- | ----- |
| APP_ENV | Miljøet appen skal knyttes seg mot, **production** eller **staging** | staging |
| SERVER_PORT | Porten integrasjonspunktet skal benytte. Dersom porten er < 1024 vil integrasjonspunktet kjøre som root i konteineren. Kan overstyres av WEBSITES_PORT i Web App-oppsettet. Porten eksponeres uansett aldri mot Internett når integrasjonspunktet kjøres som en Web App. | 9093 |
| ORG_NR | Organisasjonsnummeret til organisasjonen som eier virksomhetssertifikatet | 974760223 |
| KEYSTORE_FILE | filnavnet til keystore-fila som har virksomhetssertifikatet | auth.p12 |
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
| MESSAGE_TTL | Levetid i timer for hvor lenge en melding skal ligge før den erklæres som utgått | 24 |

## Avhengigheter ##

1. Virksomhetssertfikatet for DiBK må ligge i Key Vault spesifisert med variabelen AZURE_KV_NAME, og sertifikatet må ha et navn som korresponderer med variabelen AZURE_KV_CERT_NAME.
2. CA-sertifikatene til BuyPass og/eller Commfides må være tilgjengelige, slik at de kan bli installerte i Java sin truststore. URL til disse er satt opp som env-variabler i [build-and-deploy.yml](.github/workflows/build-and-deploy.yml), og må endres dersom de ikke lenger fungerer.
3. Tjenernavnet til Altinn sitt produksjonsmiljø (**altinn.no**) finnes som build-arg ALTINN_HOST i [Dockerfile](docker/Dockerfile). Dette brukes også til å legge tjenerens sertifikat inn i truststore. Dersom Altinn bytter navn på tjeneren kan man endre variabelen **ALTINN_HOST** i repoet.