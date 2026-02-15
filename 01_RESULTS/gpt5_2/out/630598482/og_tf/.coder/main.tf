terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.7.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

##### Variables
variable "python_version" {
  description = "Python Version?"
  default     = "3.10"
  validation {
    condition     = contains(["3.10", "3.11", "3.12"], var.python_version)
    error_message = "Version must be 3.10, 3.11, 3.12"
  }
}
variable "node_version" {
  description = "Python Version?"
  default     = "lts"
  validation {
    condition     = contains(["14", "16", "18", "20", "lts"], var.node_version)
    error_message = "Version must be 14, 16, 18, 20, lts"
  }
}

variable "cpu" {
  description = "How many CPU cores for this workspace? (max 8 cores)"
  default     = "2"
  validation {
    condition     = contains(["2", "4", "8"], var.cpu)
    error_message = "Invalid CPU count!"
  }
}
variable "ram" {
  description = "Choose RAM for your workspace? (min: 2 GB, max: 16 GB)"
  default     = "2"
  validation {
    condition     = contains(["2", "4", "8", "10", "12", "16"], var.ram)
    error_message = "Ram size must be an integer between 2 and 16 (GB)."
  }
}

variable "share_vscode" {
  description = "Share Code Server?"
  default     = "authenticated"
  validation {
    condition     = contains(["owner", "authenticated", "public"], var.share_vscode)
    error_message = "Share level must be owner, authenticated, public"
  }
}
variable "share_app" {
  description = "Share Pynecone (3000, 8000)?"
  default     = "public"
  validation {
    condition     = contains(["owner", "authenticated", "public"], var.share_app)
    error_message = "Share level must be owner, authenticated, public"
  }
}
variable "dotfiles_uri" {
  description = "Dotfiles URI (optional), see https://dotfiles.github.io"
  default     = ""
}

locals {
  coder_identify = "${lower(data.coder_workspace.me.owner)}-${lower(data.coder_workspace.me.name)}"
  network_name   = "coder-network-${local.coder_identify}"
}
##### Variables - END

resource "coder_metadata" "info" {
  count       = data.coder_workspace.me.start_count
  icon        = "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/python/python.png"
  resource_id = docker_container.workspace[0].id
  item {
    key   = "Python Version"
    value = "v ${var.python_version}"
  }
  item {
    key   = "Nodejs Version"
    value = "v ${var.node_version}"
  }
  item {
    key   = "CPU"
    value = var.cpu
  }
  item {
    key   = "RAM"
    value = var.ram
  }
  item {
    key   = "dotfiles"
    value = var.dotfiles_uri
  }
}

##### code-server
resource "coder_agent" "main" {
  arch           = "amd64"
  os             = "linux"
  startup_script = <<EOF
    #!/bin/sh
    # install and start code-server
    curl -fsSL https://code-server.dev/install.sh | sh
    code-server --auth none --port 13337 &
    coder dotfiles -y ${var.dotfiles_uri}
    EOF

  env = {
    GIT_AUTHOR_NAME     = "${data.coder_workspace.me.owner}"
    GIT_COMMITTER_NAME  = "${data.coder_workspace.me.owner}"
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace.me.owner_email}"
    GIT_COMMITTER_EMAIL = "${data.coder_workspace.me.owner_email}"
  }
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VS Code"
  url          = "http://localhost:13337/?folder=/home/coder"
  icon         = "/icon/code.svg"
  share        = var.share_vscode
}

resource "coder_app" "fastapi" {
  agent_id     = coder_agent.main.id
  slug         = "fastapi"
  display_name = "FastAPI"
  url          = "http://localhost:8000"
  icon         = "https://styles.redditmedia.com/t5_22y58b/styles/communityIcon_r5ax236rfw961.png"
  share        = var.share_app
  subdomain    = true
}

resource "coder_app" "react" {
  agent_id     = coder_agent.main.id
  slug         = "react"
  display_name = "React"
  url          = "http://localhost:3000"
  icon         = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/1200px-React-icon.svg.png"
  share        = var.share_app
  subdomain    = true
}

##### code-server - END

##### provider, data
provider "coder" {}

data "coder_workspace" "me" {}
##### provider - END

##### coder
resource "docker_network" "network" {
  name = local.network_name
}

resource "docker_image" "main" {
  name = "coder-python-${local.coder_identify}"
  build {
    context = "./build"
    build_args = {
      PYTHON_VER = var.python_version
      NODE_VER   = var.node_version
    }
  }
}

resource "docker_volume" "home_volume" {
  name = "coder-${local.coder_identify}-root"
}

resource "docker_container" "workspace" {
  count      = data.coder_workspace.me.start_count
  image      = docker_image.main.name
  cpu_shares = var.cpu * 1
  memory     = var.ram * 1024
  runtime    = "sysbox-runc"

  name = "coder-${local.coder_identify}"
  dns  = ["1.1.1.1"]

  # Refer to Docker host when Coder is on localhost
  command = ["sh", "-c", replace(coder_agent.main.init_script, "127.0.0.1", "host.docker.internal")]
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
  ]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }

  networks_advanced {
    name    = local.network_name
    aliases = ["app"]
  }

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
##### coder - END
