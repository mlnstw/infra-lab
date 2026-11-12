# resource "yandex_vpc_security_group" "k8s_master_sg" {
#   name       = "k8s-master-sg"
#   network_id = yandex_vpc_network.mlnstw-vpc.id

#   ingress {
#     protocol       = "TCP"
#     port           = 443
#     v4_cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     protocol       = "ANY"
#     v4_cidr_blocks = ["192.168.0.0/16"]
#   }

#   egress {
#     protocol       = "ANY"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "yandex_vpc_security_group" "k8s_nodes_sg" {
#   name       = "k8s-nodes-sg"
#   network_id = yandex_vpc_network.mlnstw-vpc.id

#   ingress {
#     protocol          = "ANY"
#     security_group_id = yandex_vpc_security_group.k8s_master_sg.id
#   }
#   ingress {
#     protocol       = "TCP"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 80
#   }
#   ingress {
#     protocol       = "TCP"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port      = 30000
#     to_port        = 32767
#   }
#   ingress {
#     protocol       = "ANY"
#     v4_cidr_blocks = ["10.0.0.0/16"]
#   }
#   ingress {
#     protocol       = "UDP"
#     v4_cidr_blocks = ["192.168.0.0/16"]
#     port           = 53
#   }
#   ingress {
#     protocol       = "TCP"
#     v4_cidr_blocks = ["192.168.0.0/16"]
#   }
#   ingress {
#     protocol       = "TCP"
#     v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24", "198.18.241.0/24"]
#     port           = 10256
#   }
#   ingress {
#     protocol       = "TCP"
#     v4_cidr_blocks = ["10.0.0.0/16"]
#     port           = 10256
#   }

#   egress {
#     protocol       = "ANY"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#   }
# }

resource "yandex_vpc_security_group" "k8s_master_sg" {
  name       = "k8s-master-sg"
  network_id = yandex_vpc_network.mlnstw-vpc.id

  # --- Обязательные правила из доки YC ---

  # Healthchecks от YC Network Load Balancer
  ingress {
    protocol          = "TCP"
    from_port         = 0
    to_port           = 65535
    predefined_target = "loadbalancer_healthchecks"
  }

  # Трафик к себе (для HA-мастера, безопасно и для зонального)
  ingress {
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  # ICMP-проверки работоспособности из подсетей YC
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  }

  # --- Доступ к apiserver ---

  # Внешний kubectl (порт 443)
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubelet и поды с нод (ноды стоят в 192.168.x.x)
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  # Поды напрямую (calico-typha, вебхуки, metrics-server-клиенты) — были заблокированы!
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  # Сервисы напрямую
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["10.1.0.0/16"]
  }

  # --- Исходящий ---

  egress {
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_nodes_sg" {
  name       = "k8s-nodes-sg"
  network_id = yandex_vpc_network.mlnstw-vpc.id

  # --- Обязательные правила из доки YC ---

  # Healthchecks от YC Network Load Balancer (для Service type=LoadBalancer)
  ingress {
    protocol          = "TCP"
    from_port         = 0
    to_port           = 65535
    predefined_target = "loadbalancer_healthchecks"
  }

  # Нода-к-ноде: Calico IP-in-IP, BGP, ICMP между нодами
  ingress {
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  # ICMP-проверки из подсетей YC
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  }

  # --- Трафик внутри кластера ---

  # Между подами (pod CIDR)
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  # Между сервисами (service CIDR) — РАНЬШЕ ЭТОГО НЕ БЫЛО!
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["10.1.0.0/16"]
  }

  # Мастер → нода (kube-apiserver → kubelet 10250, coredns, webhook)
  ingress {
    protocol          = "ANY"
    security_group_id = yandex_vpc_security_group.k8s_master_sg.id
  }

  # --- Трафик из своей сети (нода-к-ноде по IP) ---
  # Заменили TCP на ANY — чтобы прошёл IP-in-IP (протокол 4) и UDP
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  # DNS (UDP 53) для kube-dns → upstream
  ingress {
    protocol       = "UDP"
    v4_cidr_blocks = ["192.168.0.0/16"]
    port           = 53
  }

  # --- Внешний трафик ---

  # Приложение напрямую (порт 80)
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  # NodePort (если приложение будет доступно через NodePort)
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  # --- Исходящий ---

  egress {
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  # Узлы → Container Registry, Object Storage, интернет (через NAT)
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}