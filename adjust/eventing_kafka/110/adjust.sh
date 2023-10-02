#!/bin/bash

sed -i '/^source.*/a export USER=$\(whoami\)' test/e2e-tests.sh
sed -i 's/^\(TEST_PARALLEL=\).*/\13/' test/e2e-tests.sh
