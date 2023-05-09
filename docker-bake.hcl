variable "APP_VERSION" {
  default = null
}
variable "APP_DIR" {
  default = null
}
variable "APP_ENV" {
  default = null
}
variable "ALTINN_HOST" {
  default = "altinn.no"
}
variable "SERVER_PORT" {
  default = "9093"
}
variable "S6_OVERLAY_VERSION" {
  default = "3.1.4.2"
}

group "default" {
  targets = ["staging"]
}

target "production" {
  dockerfile = "docker/Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  args = {
    APP_VERSION = APP_VERSION
    ALTINN_HOST = ALTINN_HOST
    APP_DIR = APP_DIR
    profile = APP_ENV
    SERVER_PORT = SERVER_PORT
    S6_OVERLAY_VERSION = S6_OVERLAY_VERSION
  }
  tags = [
    "dibknoe.azurecr.io/app/integrasjonspunkt:latest", 
    "dibknoe.azurecr.io/app/integrasjonspunkt:${APP_VERSION}"
  ]
}

target "staging" {
  inherits = ["production"]
  tags = ["dibknoe.azurecr.io/app/integrasjonspunkt:${APP_ENV}", "dibknoe.azurecr.io/app/integrasjonspunkt:${APP_ENV}-${APP_VERSION}"]
}


