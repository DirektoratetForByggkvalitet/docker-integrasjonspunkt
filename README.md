# LES MEG

Docker-image som kjører DiBK sitt integrasjonspunkt mot Digdir i Azure. 

Integrasjonspunktet kjører med støtte fra MySQL-database, og lagrer dermed ingenting lokalt.

Konfigurasjonsfilen befolkes fra Bitbucket Pipelines ved bygging. Samtidig hentes også virksomhetssertifikatet fra Azure Key Vault, og public key lagres til en pkcs12-fil.
## Innstillinger for App Service

- WEBSITES_PORT må settes til 9093
- WEBSITES_CONTAINER_START_TIME_LIMIT bør settes til max, 1800 (standard er 230 sekunder). Dette for at containeren skal ha tid til å starte opp
- Health Check kan settes opp med URL /manage/health
