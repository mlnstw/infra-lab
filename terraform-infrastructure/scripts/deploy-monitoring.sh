#!/bin/bash
set -e

echo " Deploying kube-prometheus "

MONITORING_DIR="03-monitoring/kube-prometheus"

# Применяем CRD и ожидаем их готовности
kubectl apply --server-side=true --force-conflicts -f "${MONITORING_DIR}/manifests/setup"

sleep 10
kubectl wait --for condition=established --timeout=60s crd/prometheuses.monitoring.coreos.com
kubectl wait --for condition=established --timeout=60s crd/alertmanagers.monitoring.coreos.com
kubectl wait --for condition=established --timeout=60s crd/servicemonitors.monitoring.coreos.com
kubectl wait --for condition=established --timeout=60s crd/podmonitors.monitoring.coreos.com

kubectl apply -f "${MONITORING_DIR}/manifests/"

echo " kube-prometheus deploy successfull "