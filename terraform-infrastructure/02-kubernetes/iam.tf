resource "yandex_iam_service_account" "k8s-cluster-sa" {
  name = "k8s-cluster-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-cluster-roles" {
  for_each = toset([
    "load-balancer.admin",
    "vpc.publicAdmin",
    "k8s.clusters.agent"
  ])

  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s-cluster-sa.id}"
}

resource "yandex_iam_service_account" "k8s-nodes-sa" {
  name = "k8s-nodes-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-nodes-roles" {
  for_each = toset([
    "container-registry.images.puller",
  ])

  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s-nodes-sa.id}"
}

