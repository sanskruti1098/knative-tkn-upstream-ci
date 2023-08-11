#!/bin/bash

sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
echo "Increase e2e timeout to 60m"
sed -i "s/\(go_test_e2e.*\)timeout=30m\(.*\).*/\1timeout=60m\2/g" test/e2e-tests.sh

echo "Use ppc64le supported zipkin image"
sed -i  "s/image:.*/image: registry.apps.a9367076.nip.io\/openzipkin\/zipkin:test/g" test/config/monitoring/monitoring.yaml

echo "Source code patched successfully"