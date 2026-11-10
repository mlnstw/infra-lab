resource "yandex_iam_service_account" "k8s-cluster-sa" {
  name = "k8s-cluster-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-cluster-roles" {
  for_each = toset([
    "load-balancer.admin",
    "vpc.admin",
    "logging.viewer",
    "logging.writer",
    "k8s.clusters.agent",
    "container-registry.images.puller"
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
