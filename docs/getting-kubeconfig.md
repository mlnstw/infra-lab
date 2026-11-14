# Getting a kubeconfig

Three different paths depending on **who** needs access and **why**.

## 1. Human, local shell (you, debugging)

```bash
yc managed-kubernetes cluster get-credentials --name mlnstw-k8s --external --force
kubectl get nodes
