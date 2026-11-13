
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
		bucket     = "zhukov-net-ft-state"
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

