data "yandex_iam_service_account" "ci-cd-sa" {
  name = "ci-cd-sa"
}

resource "yandex_kubernetes_cluster_iam_member" "ci_cd_editor" {
  cluster_id = yandex_kubernetes_cluster.mlnstw-k8s.id
  role       = "k8s.cluster-api.editor"
  member     = "serviceAccount:${data.yandex_iam_service_account.ci-cd-sa.id}"
}

data "yandex_iam_service_account" "terraform_sa" {
  name = "mlnstw-sa"
}

resource "yandex_kubernetes_cluster_iam_member" "terraform_sa_admin" {
  cluster_id = yandex_kubernetes_cluster.mlnstw-k8s.id
  role       = "k8s.cluster-api.cluster-admin"
  member     = "serviceAccount:${data.yandex_iam_service_account.terraform_sa.id}"
}
