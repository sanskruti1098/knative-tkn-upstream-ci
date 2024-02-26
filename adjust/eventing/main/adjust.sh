#!/bin/bash

# Merge conformance test into the main e2e test
linesofcode=$(grep -A 100 go_test_e2e test/e2e-conformance-tests.sh  | grep -v success | tr '\n' ' ')
sed -i "/^success.*/i $linesofcode" test/e2e-tests.sh

sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
echo "Increase e2e timeout to 60m"
sed -i "s/\(go_test_e2e.*\)timeout=1h\(.*\).*/\1timeout=15m\2/g" test/e2e-tests.sh
sed -i "s/\(go_test_e2e.*\)parallel=20\(.*\).*/\1parallel=1\2/g" test/e2e-tests.sh

echo "Use ppc64le supported zipkin image"
sed -i "s|image:.*|image: icr.io/upstream-k8s-registry/knative/openzipkin/zipkin:test|g" test/config/monitoring/monitoring.yaml
sed -i "/^success.*/i .\/destroy.sh $1" test/e2e-rekt-tests.sh
sed -i "/^success.*/i .\/destroy.sh $1" test/e2e-tests.sh
sed -i "/.*dump_cluster_state().*/a\  .\/destroy.sh $1" vendor/knative.dev/hack/infra-library.sh 
kubectl get cm vcm-script -n default -o jsonpath='{.data.script}' > destroy.sh && chmod +x destroy.sh
echo "Source code patched successfully"
