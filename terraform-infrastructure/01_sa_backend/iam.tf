resource "yandex_iam_service_account" "sa-project" {
  name = var.sa_name
}

resource "yandex_resourcemanager_folder_iam_member" "roles" {
  for_each = toset([
    "storage.admin",
    "vpc.admin",
    "vpc.user",
    "k8s.admin",
    "iam.serviceAccounts.admin",
    "container-registry.admin",
    "resource-manager.admin",
  ])

  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.sa-project.id}"
}

resource "yandex_iam_service_account_key" "sa-key" {
  service_account_id = yandex_iam_service_account.sa-project.id
  key_algorithm      = "RSA_2048"
}

resource "local_file" "sa-key-json" {
  content = jsonencode({
    id                 = yandex_iam_service_account_key.sa-key.id
    service_account_id = yandex_iam_service_account_key.sa-key.service_account_id
    created_at         = yandex_iam_service_account_key.sa-key.created_at
    key_algorithm      = yandex_iam_service_account_key.sa-key.key_algorithm
    public_key         = yandex_iam_service_account_key.sa-key.public_key
    private_key        = yandex_iam_service_account_key.sa-key.private_key
  })
  filename = "../keys/terraform-key.json"
  provisioner "local-exec" {
    command = "chmod 600 ../keys/terraform-key.json"
  }
}

resource "yandex_iam_service_account_static_access_key" "s3-key" {
  service_account_id = yandex_iam_service_account.sa-project.id
}

resource "local_sensitive_file" "access_key" {
  content  = yandex_iam_service_account_static_access_key.s3-key.access_key
  filename = "../keys/access_key.txt"
}

resource "local_sensitive_file" "secret_key" {
  content  = yandex_iam_service_account_static_access_key.s3-key.secret_key
  filename = "../keys/secret_key.txt"
}

resource "local_file" "backend-config" {
  content  = <<-EOT

terraform {
	required_providers {
		yandex = {
			source = "yandex-cloud/yandex"
		}
    kubernetes = {
			source = "hashicorp/kubernetes"
		}
	}
	required_version = "~>1.8.4"
	backend "s3" {
		endpoints   = {
			s3 = "https://storage.yandexcloud.net"
		}
		bucket     = "${yandex_storage_bucket.tf-state.bucket}"
		region     = "ru-central1"
		key        = "terraform.tfstate"

		skip_region_validation      = true
		skip_credentials_validation = true
		skip_requesting_account_id  = true
		skip_s3_checksum            = true
	}
}

provider "yandex" {
	cloud_id                 = var.cloud_id
	folder_id                = var.folder_id
	zone                     = var.default_zone
	service_account_key_file = file("../keys/terraform-key.json")
	# service_account_key_file = var.service_account_key_file
}

data "yandex_client_config" "client" {}

provider "kubernetes" {
	host                   = yandex_kubernetes_cluster.mlnstw-k8s.master[0].external_v4_endpoint
	cluster_ca_certificate = yandex_kubernetes_cluster.mlnstw-k8s.master[0].cluster_ca_certificate
	token                  = data.yandex_client_config.client.iam_token
}

  EOT
  filename = "../02-kubernetes/backend.tf"
}

resource "yandex_iam_service_account" "ci-cd-sa" {
  name = "ci-cd-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "ci-cd-roles" {
  for_each = toset([
    "container-registry.images.pusher",
  ])

  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.ci-cd-sa.id}"
}

resource "yandex_iam_service_account_key" "ci-cd-sa-key" {
  service_account_id = yandex_iam_service_account.ci-cd-sa.id
  key_algorithm      = "RSA_2048"
}

resource "local_sensitive_file" "ci-cd-key-json" {
  count = var.generate_local_files ? 1 : 0

  content = jsonencode({
    id                 = yandex_iam_service_account_key.ci-cd-sa-key.id
    service_account_id = yandex_iam_service_account_key.ci-cd-sa-key.service_account_id
    created_at         = yandex_iam_service_account_key.ci-cd-sa-key.created_at
    key_algorithm      = yandex_iam_service_account_key.ci-cd-sa-key.key_algorithm
    public_key         = yandex_iam_service_account_key.ci-cd-sa-key.public_key
    private_key        = yandex_iam_service_account_key.ci-cd-sa-key.private_key
  })
  filename = "../keys/ci-cd-key.json"

  provisioner "local-exec" {
    command = "chmod 600 ../keys/ci-cd-key.json"
  }
}