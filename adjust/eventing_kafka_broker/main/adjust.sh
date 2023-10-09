#!/bin/bash
#Export USER before test starts
sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
#Increase e2e timeout to 60m
sed -i "s/\(go_test_e2e.*\)timeout=20m\(.*\).*/\1timeout=40m\2/g" test/e2e-tests.sh
sed -i "/^success.*/i .\/destroy.sh $1" test/e2e-tests.sh
sed -i "/.*dump_cluster_state().*/a\  .\/destroy.sh $1" vendor/knative.dev/hack/infra-library.sh
kubectl get cm vcm-script -n default -o jsonpath='{.data.script}' > destroy.sh && chmod +x destroy.sh
kubectl get cm kb-patch -n default -o jsonpath='{.data.kbpatch}' > ppc64le.patch && git apply ppc64le.patch
echo "Source code patched successfully"
