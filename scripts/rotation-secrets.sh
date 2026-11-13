#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYS="$REPO_ROOT/terraform-infrastructure/keys"

if ! gh auth status &>/dev/null; then
  echo "Сначала залогинься: gh auth login"
  exit 1
fi

for f in ci-cd-key.json terraform-key.json access_key.txt secret_key.txt; do
  if [ ! -f "$KEYS/$f" ]; then
    echo "Нет файла $KEYS/$f — прогони terraform в 01 и 02"
    exit 1
  fi
done

gh secret set YC_SERVICE_ACCOUNT_KEY_JSON < "$KEYS/ci-cd-key.json"
gh secret set YC_TERRAFORM_KEY_JSON     < "$KEYS/terraform-key.json"
gh secret set AWS_ACCESS_KEY_ID         < "$KEYS/access_key.txt"
gh secret set AWS_SECRET_ACCESS_KEY     < "$KEYS/secret_key.txt"

FOLDER_ID=$(cd "$REPO_ROOT/terraform-infrastructure/01_sa_backend" && terraform output -raw folder_id)
gh secret set YC_FOLDER_ID         --body "$FOLDER_ID"

CLOUD_ID=$(cd "$REPO_ROOT/terraform-infrastructure/01_sa_backend" && terraform output -raw cloud_id)
gh secret set YC_CLOUD_ID          --body "$CLOUD_ID"

REGISTRY=$(cd "$REPO_ROOT/terraform-infrastructure/01_sa_backend" && terraform output -raw container_registry_url)
gh secret set YC_CONTAINER_REGISTRY --body "$REGISTRY"

echo "✅ Все секреты добавлены"