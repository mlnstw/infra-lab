resource "yandex_vpc_network" "mlnstw-vpc" {
  name = var.vpc_net_name
}

resource "yandex_vpc_gateway" "neto-nat-gateway" {
  name = "neto-nat-gateway"
  shared_egress_gateway {

  }
}

resource "yandex_vpc_route_table" "private-rt" {
  name       = "mlnstw-private-rt"
  network_id = yandex_vpc_network.mlnstw-vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.neto-nat-gateway.id
  }

  depends_on = [yandex_vpc_network.mlnstw-vpc]
}

resource "yandex_vpc_subnet" "mlnstw-subnet" {
  for_each = var.conf_subnet

  name           = each.value.name
  zone           = each.value.zone
  network_id     = yandex_vpc_network.mlnstw-vpc.id
  v4_cidr_blocks = each.value.v4_cidr_blocks

  route_table_id = each.value.is_private ? yandex_vpc_route_table.private-rt.id : null

  depends_on = [yandex_vpc_route_table.private-rt]

}


