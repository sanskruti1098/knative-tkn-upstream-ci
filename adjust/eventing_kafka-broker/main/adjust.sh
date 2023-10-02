#!/bin/bash

sed -i "/^source.*/a export USER=$\(whoami\)" test/e2e-tests.sh
