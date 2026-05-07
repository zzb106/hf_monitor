#!/bin/bash

# Setup temporary test environment
setup_env() {
    TEST_DIR=$(mktemp -d)
    export HF_BASE_DIR="$TEST_DIR"
    export PATH="$TEST_DIR/mocks:$PATH"
    mkdir -p "$TEST_DIR/mocks"

    # Mock hf
    cat <<EOF > "$TEST_DIR/mocks/hf"
#!/bin/bash
if [ -f "$TEST_DIR/.hf_fail" ]; then
    rm "$TEST_DIR/.hf_fail"
    exit 1
fi
exit 0
EOF
    chmod +x "$TEST_DIR/mocks/hf"
}

cleanup_env() {
    rm -rf "$TEST_DIR"
}

# Test 1: Successful download
echo "Running Test 1: Successful download..."
setup_env
./download_hf_model.sh "test-model"
if [ $? -eq 0 ] && [ ! -d "$TEST_DIR/models/test-model/.download.lock" ]; then
    echo "Test 1 Passed"
else
    echo "Test 1 Failed"
    cleanup_env
    exit 1
fi
cleanup_env

# Test 2: Lock prevents concurrent runs
echo "Running Test 2: Lock prevents concurrent runs..."
setup_env
mkdir -p "$TEST_DIR/models/locked-model/.download.lock"
./download_hf_model.sh "locked-model"
if [ $? -eq 0 ]; then
    echo "Test 2 Passed"
else
    echo "Test 2 Failed"
    cleanup_env
    exit 1
fi
cleanup_env

# Test 3: Retry loop works
echo "Running Test 3: Retry loop works..."
setup_env
touch "$TEST_DIR/.hf_fail"
./download_hf_model.sh "retry-model" &
PID=$!
sleep 2
if kill -0 $PID 2>/dev/null; then
    echo "Test 3 Passed (script is retrying)"
    kill $PID
else
    echo "Test 3 Failed (script exited prematurely)"
    cleanup_env
    exit 1
fi
cleanup_env

# Test 4: Permission denied for base directory
echo "Running Test 4: Permission denied for base directory..."
setup_env
# Make base directory read-only
chmod 555 "$TEST_DIR"
./download_hf_model.sh "perm-model" 2>/dev/null
# The script should fail because it can't mkdir -p $TARGET
# Note: we use a subshell or ignore error since we just want to see it doesn't crash wildly
if [ $? -ne 0 ]; then
    echo "Test 4 Passed (failed as expected)"
else
    echo "Test 4 Failed (should have failed due to permissions)"
    # restore permissions to allow cleanup
    chmod 755 "$TEST_DIR"
    cleanup_env
    exit 1
fi
chmod 755 "$TEST_DIR"
cleanup_env

echo "All download tests passed!"
exit 0
