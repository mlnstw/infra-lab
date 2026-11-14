# conf_vm = {
#   "nat-instance" = {
#     name          = "nat-instance"
#     hostname      = "nat-instance"
#     zone          = "ru-central1-a"
#     platform_id   = "standard-v3"
#     core          = 2
#     memory        = 2
#     core_fraction = 20
#     image_id      = "fd84rm55cmi1etioc90r"
#     disk_size     = 20
#     subnet_name   = "public-a"
#     nat           = true
#     ip_address    = "192.168.10.254"
#   }
#   "bastion" = {
#     name          = "bastion"
#     hostname      = "bastion"
#     zone          = "ru-central1-a"
#     platform_id   = "standard-v3"
#     core          = 2
#     memory        = 2
#     core_fraction = 20
#     image_id      = "fd8pob68hkr4moafr5jm"
#     disk_size     = 20
#     subnet_name   = "public-a"
#     nat           = true
#     ip_address    = "192.168.10.10"
#   }
# }

conf_subnet = {
  "public-a" = {
    name           = "public-a"
    zone           = "ru-central1-a"
    v4_cidr_blocks = ["192.168.10.0/24"]
    is_private     = false
  }
  "private-a" = {
    name           = "private-a"
    zone           = "ru-central1-a"
    v4_cidr_blocks = ["192.168.20.0/24"]
    is_private     = true
  }
  "private-e" = {
    name           = "private-e"
    zone           = "ru-central1-e"
    v4_cidr_blocks = ["192.168.30.0/24"]
    is_private     = true
  }
  "private-d" = {
    name           = "private-d"
    zone           = "ru-central1-d"
    v4_cidr_blocks = ["192.168.40.0/24"]
    is_private     = true
  }
  "k8s-masters-a" = {
    name           = "k8s-masters-a"
    zone           = "ru-central1-a"
    v4_cidr_blocks = ["192.168.50.0/24"]
    is_private     = true
  }
  # "k8s-masters-b" = {
  #   name           = "k8s-masters-b"
  #   zone           = "ru-central1-e"
  #   v4_cidr_blocks = ["192.168.60.0/24"]
  #   is_private     = true
  # }
  # "k8s-masters-d" = {
  #   name           = "k8s-masters-d"
  #   zone           = "ru-central1-d"
  #   v4_cidr_blocks = ["192.168.70.0/24"]
  #   is_private     = true
  # }
}
