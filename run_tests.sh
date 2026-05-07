#!/bin/bash

# Ensure test scripts are executable
chmod +x tests/test_download.sh tests/test_update.sh tests/test_cron.sh

FAILED=0

echo "Running Test Suite..."
echo "--------------------"

./tests/test_download.sh || { echo "Download tests failed"; FAILED=1; }
./tests/test_update.sh || { echo "Update tests failed"; FAILED=1; }
./tests/test_cron.sh || { echo "Cron tests failed"; FAILED=1; }

echo "--------------------"
if [ $FAILED -eq 0 ]; then
    echo "ALL TESTS PASSED"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
