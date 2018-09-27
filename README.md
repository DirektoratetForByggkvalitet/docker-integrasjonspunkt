# READ ME

This is a docker image built to facilitate "Difi integrasjonspunkt" inside Docker. It is based on java:8-jdk.

Generally, it leans on the files auth.jks and integrasjonspunkt-local.properties, which enables authorisation and setup for use. Both these are installed in /integrasjonspunkt, along with the integrasjonspunkt.jar application file.

The image exposes port 9094, and will log all activity to the docker log.