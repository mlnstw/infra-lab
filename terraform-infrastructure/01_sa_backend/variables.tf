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

variable "bucket_name" {
  type    = string
  default = "mlnstw"
}

variable "sa_name" {
  type    = string
  default = "mlnstw"
}

variable "generate_local_files" {
  type    = bool
  default = false
}