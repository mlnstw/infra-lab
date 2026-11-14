## 1. IAM model — rationale

**Why `k8s-cluster-sa` needs `load-balancer.admin`:**
Managed K8s control plane lives in Yandex Cloud. When you create `Service type=LoadBalancer`,
the *control plane* (not the nodes) calls Yandex API to provision the NLB. Without this role,
services with `EXTERNAL-IP` stay `Pending` forever. This is a common gotcha.

**Why `k8s-nodes-sa` needs `container-registry.images.puller`:**
Worker nodes pull images on behalf of pods. The nodes' SA (not the pod's SA) is used for
this by default in managed K8s. Without it, pods go to `ImagePullBackOff` with
"unauthorized" from registry.

**Why `ci-cd-sa` has both folder-level `k8s.viewer` AND cluster-level `k8s.cluster-api.editor`:**
- Folder `k8s.viewer` → allows `yc managed-kubernetes cluster get-credentials` (reads cluster info)
- Cluster `k8s.cluster-api.editor` → allows `kubectl apply` inside namespaces (K8s RBAC group `yc:editor`)
- Without folder role, `get-credentials` returns `PermissionDenied` (can't even list clusters)
- Without cluster role, `kubectl apply` returns `Forbidden` (can't create deployments)

---

## 2. Terraform state

- S3 backend, bucket `zhukov-net-ft-state`, versioning enabled
- **No locking.** S3 backend in Terraform supports locking only via DynamoDB.
  Yandex Object Storage doesn't have an equivalent, so concurrent `apply` can corrupt state.
  Mitigation: `infra-kubernetes.yml` runs `apply` only on push to `master` (serialized by GitHub).
- **Two-phase apply** for K8s resources: cluster + IAM bindings first, then K8s SA + RBAC.
  Why: cluster creation takes ~10 min, then IAM propagation 1–5 min. If you create
  `kubernetes_service_account` in the same apply, it fails with `Forbidden` because
  Terraform's SA hasn't propagated cluster-admin yet. Solution: `-target` first pass,
  then full apply.

---

## 3. CI/CD sequencing

### Why Kustomize and not `sed`

Early versions used `sed -i "s|{{ REGISTRY }}|...|g" deployment.yaml`. Problems:
- Fragile: `sed` pattern must exactly match placeholder (`{{ REGISTRY }}` vs `${REGISTRY}`)
- Broken YAML: replacing inside YAML without escaping led to parse errors (we hit this)
- Non-standard: Kubernetes ecosystem uses Kustomize for image substitution

Kustomize keeps `deployment.yaml` clean (`image: mlnstw-test-app:latest`) and does
`kustomize edit set image` before `kubectl apply -k`.
