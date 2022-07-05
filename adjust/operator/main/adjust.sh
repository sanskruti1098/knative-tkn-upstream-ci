#!/bin/bash

#Export USER before test starts
sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
#Increase e2e timeout to 60m
sed -i "s/\(go_test_e2e.*\)timeout=45m\(.*\).*/\1timeout=60m\2/g" test/e2e-tests.sh