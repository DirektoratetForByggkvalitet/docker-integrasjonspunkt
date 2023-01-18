# LES MEG

This is a docker image built to facilitate "Difi integrasjonspunkt" inside Docker. It is based on java:8-jdk.

Generally, it leans on the files auth.jks and integrasjonspunkt-local.properties, which enables authorisation and setup for use. Both these are installed in /integrasjonspunkt upon build, along with the integrasjonspunkt.jar application file. We have provided a sample properties file for convinience.

The image exposes port 9093, and will log all activity to the docker log.

## Innstillinger for App Service

WEBSITES_PORT settes til 9093
WEBSITES_CONTAINER_START_TIME_LIMIT økes til 1800 (standard er 230 sekunder)

### Path mappings
/etc/keystore => Azure Blob som inneholder auth.jks
/opt/integrasjonspunkt/activemq-data => Azure File Share
/opt/integrasjonspunkt/messages => Azure File Share
/opt/integrasjonspunkt/uploads => Azure File Share
