#!/bin/bash

sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
echo "Increase e2e timeout to 60m"
sed -i "s/\(go_test_e2e.*\)timeout=1h\(.*\).*/\1timeout=15m\2/g" test/e2e-tests.sh
sed -i "s/\(go_test_e2e.*\)parallel=20\(.*\).*/\1parallel=1\2/g" test/e2e-tests.sh

echo "Use ppc64le supported zipkin image"
sed -i "s|image:.*|image: na.artifactory.swg-devops.com/sys-linux-power-team-ftp3distro-docker-images-docker-local/knative/openzipkin/zipkin:test|g" test/config/monitoring/monitoring.yaml
sed -i "/^success.*/i .\/destroy.sh $1" test/e2e-rekt-tests.sh
sed -i "/^success.*/i .\/destroy.sh $1" test/e2e-tests.sh

kubectl get cm vcm-script -n default -o jsonpath='{.data.script}' > destroy.sh && chmod +x destroy.sh
echo "Source code patched successfully"