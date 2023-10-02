#!/bin/bash

sed -i '/^source.*/a export USER=$\(whoami\)' test/e2e-tests.sh
sed -i 's/^\(TEST_PARALLEL=\).*/\13/' test/e2e-tests.sh
kubectl get cm p-patch -n default -o jsonpath='{.data.ppc64lepatch}' > ppc64le.patch && git apply ppc64le.patch
