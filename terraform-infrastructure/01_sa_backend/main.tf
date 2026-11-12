resource "yandex_storage_bucket" "tf-state" {
  bucket = var.bucket_name
  force_destroy = true

  access_key = yandex_iam_service_account_static_access_key.s3-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.s3-key.secret_key

  versioning {
    enabled = true
  }

  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.roles]
}

resource "yandex_container_registry" "mlnstw-registry" {
  name      = "mlnstw-registry"
  folder_id = var.folder_id
}


