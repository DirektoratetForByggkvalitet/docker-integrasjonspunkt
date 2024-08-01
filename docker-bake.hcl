variable "APP_VERSION" {
  default = null
}
variable "APP_DIR" {
  default = null
}
variable "APP_ENV" {
  default = null
}

variable "SERVER_PORT" {
  default = "9093"
}
variable "S6_OVERLAY_VERSION" {
  default = null
}

variable "ACR" {
  default = "dibknoe.azurecr.io"
}
variable "ACRPATH" {
  default = "/app/integrasjonspunkt"
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
    APP_DIR = APP_DIR
    APP_ENV = APP_ENV
    SERVER_PORT = SERVER_PORT
    S6_OVERLAY_VERSION = S6_OVERLAY_VERSION
  }
  tags = [
    "${ACR}${ACRPATH}:latest", 
    "${ACR}${ACRPATH}:${APP_ENV}",
    "${ACR}${ACRPATH}:${APP_VERSION}"
  ]
}

target "staging" {
  inherits = ["production"]
  tags = ["${ACR}${ACRPATH}:${APP_ENV}", "${ACR}${ACRPATH}:${APP_ENV}-${APP_VERSION}"]
}


