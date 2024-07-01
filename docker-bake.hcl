variable "REGISTRY" {
  default = "ghcr.io/damoun"
}

target "base" {
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  labels = {
    "org.opencontainers.image.authors" = "Damien Plenard <damien@plenard.me>"
    "org.opencontainers.image.url" = "https://github.com/damoun/containers"
    "org.opencontainers.image.source" = "https://github.com/damoun/containers"
    "org.opencontainers.image.created" = "${timestamp()}"
  }
}

group "default" {
  targets = []
}

group "pixelfed" {
  targets = ["pixelfed-0-11-9"]
}

target "pixelfed-0-11-9" {
  args = {
    "PIXELFED_VERSION" = "0.11.9"
  }
  labels = {
    "org.opencontainers.image.version" = "0.11.9"
  }
  context = "pixelfed/0.11.9"
  tags = ["${REGISTRY}/pixelfed:0.11.9", "${REGISTRY}/pixelfed:latest"]
  inherits = ["base"]
}
