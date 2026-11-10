resource "yandex_vpc_security_group" "k8s_master_sg" {
  name       = "k8s-master-sg"
  network_id = yandex_vpc_network.mlnstw-vpc.id

  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_nodes_sg" {
  name       = "k8s-nodes-sg"
  network_id = yandex_vpc_network.mlnstw-vpc.id

  ingress {
    protocol          = "ANY"
    security_group_id = yandex_vpc_security_group.k8s_master_sg.id
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    protocol       = "UDP"
    v4_cidr_blocks = ["192.168.0.0/16"]
    port           = 53
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["192.168.0.0/16"]
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24", "198.18.241.0/24"]
    port           = 10256
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 10256
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

