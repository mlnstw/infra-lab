data "yandex_logging_group" "k8s_logs" {
  name      = "k8s-logs"
  folder_id = var.folder_id
}
