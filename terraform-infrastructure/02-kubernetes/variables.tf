variable "cloud_id" {
  type        = string
  description = "cloud"
}

variable "folder_id" {
  type        = string
  description = "cloud"
}

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "vpc_net_name" {
  type    = string
  default = "mlnstw-pvc"
}

variable "bucket_name" {
  type    = string
  default = "zhukov-state"
}

variable "registry_name" {
  type    = string
  default = "mlnstw"
}

variable "conf_vm" {
  type = map(object({
    name          = string
    hostname      = optional(string)
    zone          = optional(string)
    platform_id   = optional(string)
    core          = number
    memory        = number
    core_fraction = number
    image_id      = optional(string)
    disk_size     = number
    subnet_name   = optional(string)
    nat           = bool
    ip_address    = optional(string)
  }))
  default = {
    "app-1" = {
      name          = "app-1"
      hostname      = "app-1"
      zone          = "ru-central1-a"
      platform_id   = "standard-v3"
      core          = 2
      memory        = 4
      core_fraction = 20
      image_id      = "fd8hqa9l7c4q1q7kl8bh"
      disk_size     = 10
      subnet_name   = "public"
      nat           = true
      ip_address    = null
    }
  }
}

variable "conf_subnet" {
  type = map(object({
    name           = string
    zone           = optional(string)
    network_id     = optional(string)
    v4_cidr_blocks = list(string)
    route_table_id = optional(string)
    is_private     = optional(bool, false)
  }))
  default = {
    "public" = {
      name           = "public"
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["10.0.1.0/24"]
      is_private     = false
    }
  }
}

# variable "metadata" {
#   type = object({
#     serial-port-enable = number
#     ssh-keys           = string
#   })
#   default = {
#     serial-port-enable = 0
#     ssh-keys           = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINIkEUEbfRdu9vENE7/qJhmw39aKfuh2QFKBxJc8EW/x mlnstw@V580c"
#   }
# }

variable "service_account_key_file" {
  type    = string
  default = null
}

variable "generate_local_files" {
  type    = bool
  default = false
}
