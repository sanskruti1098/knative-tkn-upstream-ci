#!/bin/bash

sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
sed -i "s/\(go_test_e2e.*\)timeout=30m\(.*\).*/\1timeout=60m\2/g" test/e2e-tests.sh