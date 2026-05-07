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
exit 0
EOF
    chmod +x "$TEST_DIR/mocks/hf"

    # Mock git
    cat <<EOF > "$TEST_DIR/mocks/git"
#!/bin/bash
if [ "\$1" == "pull" ] && [ -f "$TEST_DIR/.git_fail" ]; then
    exit 1
fi
exit 0
EOF
    chmod +x "$TEST_DIR/mocks/git"

    # Mock download scripts
    cat <<EOF > "$TEST_DIR/mocks/download_hf_model.sh"
#!/bin/bash
exit 0
EOF
    cat <<EOF > "$TEST_DIR/mocks/download_hf_dataset.sh"
#!/bin/bash
exit 0
EOF
    chmod +x "$TEST_DIR/mocks/download_hf_model.sh" "$TEST_DIR/mocks/download_hf_dataset.sh"
}

cleanup_env() {
    rm -rf "$TEST_DIR"
}

run_update_test() {
    local test_name=$1
    local model_content=$2
    local dataset_content=$3
    local git_fail=${4:-false}

    echo "Running $test_name..."

    # Setup tracking files
    echo -e "$model_content" > "$TEST_DIR/models.txt"
    echo -e "$dataset_content" > "$TEST_DIR/datasets.txt"

    if [ "$git_fail" = "true" ]; then
        touch "$TEST_DIR/.git_fail"
    fi

    # Use a temporary copy of the script
    cp update_and_download.sh "$TEST_DIR/update_and_download.sh"
    chmod +x "$TEST_DIR/update_and_download.sh"

    # Patch paths to use mocks
    sed -i "s|./download_hf_model.sh|\"$TEST_DIR/mocks/download_hf_model.sh\"|g" "$TEST_DIR/update_and_download.sh"
    sed -i "s|./download_hf_dataset.sh|\"$TEST_DIR/mocks/download_hf_dataset.sh\"|g" "$TEST_DIR/update_and_download.sh"

    cd "$TEST_DIR"
    ./update_and_download.sh > /dev/null 2>&1
    local result=$?
    cd - > /dev/null

    if [ $result -eq 0 ]; then
        echo "$test_name Passed"
    else
        echo "$test_name Failed"
        return 1
    fi
}

# --- Main Execution ---

# Test 1: Standard processing
setup_env
run_update_test "Standard Processing" "model1\nmodel2" "data1\ndata2"
if [ $? -ne 0 ]; then cleanup_env; exit 1; fi
cleanup_env

# Test 2: Empty input files
setup_env
run_update_test "Empty Files" "" ""
if [ $? -ne 0 ]; then cleanup_env; exit 1; fi
cleanup_env

# Test 3: Missing input files
setup_env
# Remove files created by setup_env logic if any, but here we just don't create them in the script
# We need a custom run for this
echo "Running Missing Files Test..."
# Manually setup a dir without the txt files
T_DIR=$(mktemp -d)
cp update_and_download.sh "$T_DIR/update_and_download.sh"
chmod +x "$T_DIR/update_and_download.sh"
cd "$T_DIR"
./update_and_download.sh > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Missing Files Test Passed"
else
    echo "Missing Files Test Failed"
    rm -rf "$T_DIR"
    exit 1
fi
cd - > /dev/null
rm -rf "$T_DIR"

# Test 4: Comments and empty lines
setup_env
run_update_test "Comments and Empty Lines" "# This is a comment\n\nmodel1\n  \n# another\nmodel2" "dataset1"
if [ $? -ne 0 ]; then cleanup_env; exit 1; fi
cleanup_env

# Test 5: Git pull failure
setup_env
run_update_test "Git Pull Failure" "model1" "dataset1" "true"
if [ $? -ne 0 ]; then cleanup_env; exit 1; fi
cleanup_env

echo "All update tests passed!"
exit 0
