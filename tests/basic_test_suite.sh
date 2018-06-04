# This script handles some basic "Unit Testing" for the VM

# This tests run the specified commands when run in VM,
# and exit with return code 0 if tests are success (otherwise 1)

echo "Running tests..."
echo
echo

fail_counts=0
failures=()
total_tests_count=0

# Takes two arguments:
# 1: What is being tested (or name of testy)
# 2: Command used to test it
function test() {
  verify_args "$@"

  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "Testing: $1"
  echo "Command: $2"
  /bin/bash -c "$2" > /dev/null \
    || (echo "Command errored, trying again with sudo..." \
        && sudo /bin/bash -c "$2" > /dev/null)
  result=$?

  if (( result != 0 )); then
    echo "=> Test $1 failed."
    (( fail_counts++ ))
    # Add test-name to array
    failures+=("$1")
  else
    echo "=> Test $1 success."
  fi

  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo
  (( total_tests_count++ ))
}

function verify_args() {
  is_arg_failure=0
  # Check if number of arguments is exactly 2
  if [ $# -ne 2 ]
  then
    echo "Invalid number of arguments."
    echo "Number of arguments expected: 2"
    echo "Number of arguments found: $#"
    is_arg_failure=1
  else
    # Check if any argument is empty or null
    for arg in "$@"
    do
      if [ -z "$arg" ]
      then
        echo "Invalid argument supplied."
        is_arg_failure=1
        break
      fi
    done
  fi

  if (( is_arg_failure == 1 )); then
    echo "Exactly two arguments are required:"
    echo "-------------------------------------------"
    echo "Arg-1 (string): Test-name"
    echo "Arg-2 (string): Command to use for testing"
    echo "-------------------------------------------"
    echo "Exiting because an invalid test was found."
    exit 1
  fi
}

function display_test_results() {
  if (( fail_counts == 0 )); then
    echo "========================================================="
    echo "All $total_tests_count tests passed."
    echo "========================================================="
  else
    echo "========================================================="
    echo "$fail_counts/$total_tests_count tests failed."
    echo
    echo "Failed tests are:"
    echo "-----------------"
    for test in "${failures[@]}"
    do
      echo "$test"
    done
    echo "========================================================="
    exit 1
  fi
}

# -- Python test
test "Python" "python --version"

# -- PIP test
test "PIP" "pip --version"

# -- Ansible test
test "Ansible" "ansible --version"

# -- Docker-Compose test
test "Docker-Compose" "docker-compose --version"

display_test_results
