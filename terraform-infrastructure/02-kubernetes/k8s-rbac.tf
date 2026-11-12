data "yandex_iam_service_account" "ci_cd_sa" {
  name = "ci-cd-sa"
}

resource "yandex_kubernetes_cluster_iam_member" "ci_cd_editor" {
  cluster_id = yandex_kubernetes_cluster.mlnstw-k8s.id
  role       = "k8s.cluster-api.editor"
  member     = "serviceAccount:${yandex_iam_service_account.ci-cd-sa.id}"
}
