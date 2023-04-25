target "production" {
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    ip_version = "${ip_version}"
    ALTINN_HOST = "altinn.no"
    APP_DIR="/app/integrasjonspunkt"
  }
  tags = ["dibknoe.azurecr.io/app/integrasjonspunkt:latest", "dibknoe.azurecr.io/app/integrasjonspunkt:${ip_version}"]
}

target "staging" {
  inherits = ["production"]
  args = {
    ip_version = "${ip_version}"
    ALTINN_HOST = "tt02.altinn.no"
    APP_DIR="/app/integrasjonspunkt"
  }
  tags = ["dibknoe.azurecr.io/app/integrasjonspunkt:staging", "dibknoe.azurecr.io/app/integrasjonspunkt:staging-${ip_version}"]
}


