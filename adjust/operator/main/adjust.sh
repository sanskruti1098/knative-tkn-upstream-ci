#!/bin/bash

#Export USER before test starts
sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh