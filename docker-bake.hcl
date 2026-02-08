variable "TAG" {
  default = "slim"
}

group "default" {
  targets = ["common", "dev"]
}

target "common" {
  context = "."
  platforms = ["linux/amd64"]
}

target "regular" {
  inherits = ["common"]
  dockerfile = "Dockerfile"
  tags = [
    "runpod/comfyui:${TAG}",
    "runpod/comfyui:latest",
  ]
}

target "dev" {
  inherits = ["common"]
  dockerfile = "Dockerfile"
  tags = ["runpod/comfyui:dev"]
  output = ["type=docker"]
}

target "devpush" {
  inherits = ["common"]
  dockerfile = "Dockerfile"
  tags = ["runpod/comfyui:dev"]
}
