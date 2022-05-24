#!/bin/bash

cmd_line="./kn service create svc1 --no-wait --image \$img -e TARGET=Knative -n \$ns || fail_test\n  ./kn service create svc1 --no-wait --image \$img -e TARGET=Knative -n \$ns1 || fail_test\n  sleep 4\n  kubectl delete ns \$ns \$ns1\n  kubectl create ns \$ns || fail_test\n  kubectl create ns \$ns1 || fail_test\n  sleep 4"

go build -o kn cmd/kn/main.go
sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
sed -i '/success.*/i\  .\/destroy.sh' test/e2e-tests.sh
sed -i "/sleep.*/a\  ${cmd_line}" test/e2e-tests.sh