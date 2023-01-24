#!/command/with-env bash

d=$(date '+%d-%m-%Y %T %Z')
echo "####################################################"
echo "    D I B K    I N T E G R A S J O N S P U N K T"
echo "####################################################"
echo "Docker-konteiner for Azure Web App med:"
echo "  - Digdir Integrasjonspunkt v${APP_VERSION} (port 9093)"
echo "  - SSH (port 2222)"
echo "-----------------------------------------------------"
echo "  Tidspunkt: $d"
echo "-----------------------------------------------------"
