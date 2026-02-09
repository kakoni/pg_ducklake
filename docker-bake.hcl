variable "REPO" {
  default = "pgducklake/pgducklake"
}

variable "POSTGRES_VERSION" {
  default = "16"
}

target "shared" {
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "postgres" {
  inherits = ["shared"]

  contexts = {
    postgres_base = "docker-image://postgres:${POSTGRES_VERSION}-bookworm"
  }

  args = {
    POSTGRES_VERSION = "${POSTGRES_VERSION}"
  }

  tags = [
    "${REPO}:${POSTGRES_VERSION}-dev",
  ]
}

target "pg_ducklake" {
  inherits = ["postgres"]
  target = "output"
}

target "pg_ducklake_14" {
  inherits = ["pg_ducklake"]

  contexts = {
    postgres_base = "docker-image://postgres:14-bookworm"
  }

  args = {
    POSTGRES_VERSION = "14"
  }

  tags = [
    "${REPO}:14-dev",
  ]
}

target "pg_ducklake_15" {
  inherits = ["pg_ducklake"]

  contexts = {
    postgres_base = "docker-image://postgres:15-bookworm"
  }

  args = {
    POSTGRES_VERSION = "15"
  }

  tags = [
    "${REPO}:15-dev",
  ]
}

target "pg_ducklake_16" {
  inherits = ["pg_ducklake"]

  contexts = {
    postgres_base = "docker-image://postgres:16-bookworm"
  }

  args = {
    POSTGRES_VERSION = "16"
  }

  tags = [
    "${REPO}:16-dev",
  ]
}

target "pg_ducklake_17" {
  inherits = ["pg_ducklake"]

  contexts = {
    postgres_base = "docker-image://postgres:17-bookworm"
  }

  args = {
    POSTGRES_VERSION = "17"
  }

  tags = [
    "${REPO}:17-dev",
  ]
}

target "pg_ducklake_18" {
  inherits = ["pg_ducklake"]

  contexts = {
    postgres_base = "docker-image://postgres:18-bookworm"
  }

  args = {
    POSTGRES_VERSION = "18"
  }

  tags = [
    "${REPO}:18-dev",
  ]
}

target "default" {
  inherits = ["pg_ducklake_18"]
}
