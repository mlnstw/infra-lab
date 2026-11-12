resource "yandex_kubernetes_cluster" "mlnstw-k8s" {
  name       = "mlnstw-k8s"
  network_id = yandex_vpc_network.mlnstw-vpc.id

  master {
    version = "1.32"
    zonal {
      zone      = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.mlnstw-subnet["k8s-masters-a"].id
    }

    public_ip = true

    security_group_ids = [yandex_vpc_security_group.k8s_master_sg.id]

  }

  service_account_id      = yandex_iam_service_account.k8s-cluster-sa.id
  node_service_account_id = yandex_iam_service_account.k8s-nodes-sa.id

  cluster_ipv4_range = "10.0.0.0/16"
  service_ipv4_range = "10.1.0.0/16"

  network_policy_provider = "CALICO"

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-cluster-roles,
    yandex_resourcemanager_folder_iam_member.k8s-nodes-roles
  ]
}

resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id = yandex_kubernetes_cluster.mlnstw-k8s.id
  name       = "mlnstw-node-group"

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 4
      core_fraction = 20
    }

    boot_disk {
      type = "network-ssd"
      size = 30
    }

    network_interface {
      subnet_ids = [
        yandex_vpc_subnet.mlnstw-subnet["private-a"].id,
        yandex_vpc_subnet.mlnstw-subnet["private-e"].id,
        yandex_vpc_subnet.mlnstw-subnet["private-d"].id
      ]

      nat                = false
      security_group_ids = [yandex_vpc_security_group.k8s_nodes_sg.id]
    }

    scheduling_policy {
      preemptible = true
    }

    metadata = {
      serial-port-enable = 0
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
    location {
      zone = "ru-central1-e"
    }
    location {
      zone = "ru-central1-d"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "saturday"
      start_time = "23:00"
      duration   = "3h"
    }
  }
}

resource "local_file" "kubeconfig" {
  count = var.generate_local_files ? 1 : 0

  content = <<-EOT
    apiVersion: v1
    kind: Config
    clusters:
    - cluster:
        certificate-authority-data: ${base64encode(trimspace(yandex_kubernetes_cluster.mlnstw-k8s.master[0].cluster_ca_certificate))}
        server: ${yandex_kubernetes_cluster.mlnstw-k8s.master[0].external_v4_endpoint}
      name: ${yandex_kubernetes_cluster.mlnstw-k8s.name}
    contexts:
    - context:
        cluster: ${yandex_kubernetes_cluster.mlnstw-k8s.name}
        user: ${yandex_kubernetes_cluster.mlnstw-k8s.name}
      name: ${yandex_kubernetes_cluster.mlnstw-k8s.name}
    current-context: ${yandex_kubernetes_cluster.mlnstw-k8s.name}
    users:
    - name: ${yandex_kubernetes_cluster.mlnstw-k8s.name}
      user:
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          command: yc
          args:
          - managed-kubernetes
          - create-token
  EOT

  filename = "../keys/kubeconfig"

  provisioner "local-exec" {
    command = "chmod 600 ../keys/kubeconfig"
  }

  depends_on = [yandex_kubernetes_cluster.mlnstw-k8s]
}
