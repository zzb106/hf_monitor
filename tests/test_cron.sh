#!/bin/bash

# Setup temporary test environment
TEST_DIR=$(mktemp -d)
export PATH="$TEST_DIR/mocks:$PATH"
mkdir -p "$TEST_DIR/mocks"

# Mock crontab
cat <<EOF > "$TEST_DIR/mocks/crontab"
#!/bin/bash
if [ "\$1" == "-l" ]; then
    exit 1
fi
exit 0
EOF
chmod +x "$TEST_DIR/mocks/crontab"

# Mock which
cat <<EOF > "$TEST_DIR/mocks/which"
#!/bin/bash
echo "/usr/local/bin/hf"
exit 0
EOF
chmod +x "$TEST_DIR/mocks/which"

# Mock the update script
touch update_and_download.sh

# Run setup_cron.sh
./setup_cron.sh

if [ $? -eq 0 ]; then
    echo "Test Cron Passed"
else
    echo "Test Cron Failed"
    exit 1
fi

rm -rf "$TEST_DIR"
exit 0
