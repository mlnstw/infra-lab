output "container_registry_url" {
  value = "cr.yandex/${yandex_container_registry.mlnstw-registry.id}"
}

output "folder_id" {
  value = var.folder_id
}

output "cloud_id" {
  value = var.cloud_id
}

output "keys" {
  value = "export AWS_ACCESS_KEY_ID=$(cat ../keys/access_key.txt) && export AWS_SECRET_ACCESS_KEY=$(cat ../keys/secret_key.txt)"
}