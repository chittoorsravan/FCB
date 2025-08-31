#!/usr/bin/env bash
set -euo pipefail

NS=kube-system

echo "Patching ebs-csi-node DaemonSet with CriticalAddonsOnly toleration (idempotent)..."
kubectl -n "${NS}" patch ds ebs-csi-node --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/tolerations","value":[
    {"key":"CriticalAddonsOnly","operator":"Exists","effect":"NoSchedule"}
  ]}
]' || true

echo "Ensuring nodeSelector includes linux (Bottlerocket nodes report linux)..."
kubectl -n "${NS}" patch ds ebs-csi-node --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/nodeSelector","value":{"kubernetes.io/os":"linux"}}
]' || true

echo "Rollout and wait for ebs-csi-node..."
kubectl -n "${NS}" rollout status ds/ebs-csi-node --timeout=180s || true

echo "Check CSINode topology keys (should not be empty)..."
kubectl get csinode -o jsonpath='{range .items[*]}{.metadata.name}{" => "}{.spec.drivers[?(@.name=="ebs.csi.aws.com")].topologyKeys}{"\n"}{end}' || true

echo "EBS CSI fix script complete."
