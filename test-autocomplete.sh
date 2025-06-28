#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
  local test_name=$1
  local result=$2
  
  if [ "$result" -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Create a temporary directory for testing
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Function to clean up
cleanup() {
  echo "Cleaning up..."
  rm -rf "$TEMP_DIR"
  echo "Done."
}

# Set up trap to clean up on exit
trap cleanup EXIT

# Source the scripts-autocomplete file to make the auto-completion function available
echo "Sourcing scripts-autocomplete..."
source "$(pwd)/scripts-autocomplete"

# Test 1: Test auto-completion when not in a Git repository
echo "Test 1: Auto-completion when not in a Git repository"
cd "$TEMP_DIR"

# Set up mock variables for auto-completion
COMP_WORDS=("scripts" "gitlab" "mr-create" "")
COMP_CWORD=3
cur=""
prev="mr-create"

# Call the auto-completion function
_scripts_autocomplete

# Check if the result contains only the -m flag
if [[ "${COMPREPLY[*]}" == "-m" ]]; then
  print_result "Auto-completion when not in a Git repository" 0
else
  echo "Expected: -m"
  echo "Got: ${COMPREPLY[*]}"
  print_result "Auto-completion when not in a Git repository" 1
fi

# Test 2: Test auto-completion in a Git repository with branches
echo "Test 2: Auto-completion in a Git repository with branches"

# Initialize a Git repository
git init > /dev/null 2>&1
git config --local user.email "test@example.com" > /dev/null 2>&1
git config --local user.name "Test User" > /dev/null 2>&1

# Create an initial commit
echo "Initial commit" > README.md
git add README.md > /dev/null 2>&1
git commit -m "Initial commit" > /dev/null 2>&1

# Create some branches
git branch feature-branch > /dev/null 2>&1
git branch bugfix-branch > /dev/null 2>&1
git branch release-branch > /dev/null 2>&1

# Set up mock variables for auto-completion
COMP_WORDS=("scripts" "gitlab" "mr-create" "")
COMP_CWORD=3
cur=""
prev="mr-create"

# Call the auto-completion function
_scripts_autocomplete

# Check if the result contains branches and -m flag
if [[ "${COMPREPLY[*]}" == *"feature-branch"* && "${COMPREPLY[*]}" == *"bugfix-branch"* && "${COMPREPLY[*]}" == *"release-branch"* && "${COMPREPLY[*]}" == *"-m"* ]]; then
  print_result "Auto-completion in a Git repository with branches" 0
else
  echo "Expected: feature-branch bugfix-branch release-branch -m (in any order)"
  echo "Got: ${COMPREPLY[*]}"
  print_result "Auto-completion in a Git repository with branches" 1
fi

# Test 3: Test auto-completion with partial branch name
echo "Test 3: Auto-completion with partial branch name"

# Set up mock variables for auto-completion
COMP_WORDS=("scripts" "gitlab" "mr-create" "feat")
COMP_CWORD=3
cur="feat"
prev="mr-create"

# Call the auto-completion function
_scripts_autocomplete

# Check if the result contains only feature-branch
if [[ "${COMPREPLY[*]}" == "feature-branch" ]]; then
  print_result "Auto-completion with partial branch name" 0
else
  echo "Expected: feature-branch"
  echo "Got: ${COMPREPLY[*]}"
  print_result "Auto-completion with partial branch name" 1
fi

# Test 4: Test auto-completion with -m flag
echo "Test 4: Auto-completion with -m flag"

# Set up mock variables for auto-completion
COMP_WORDS=("scripts" "gitlab" "mr-create" "-")
COMP_CWORD=3
cur="-"
prev="mr-create"

# Call the auto-completion function
_scripts_autocomplete

# Check if the result contains only -m
if [[ "${COMPREPLY[*]}" == "-m" ]]; then
  print_result "Auto-completion with -m flag" 0
else
  echo "Expected: -m"
  echo "Got: ${COMPREPLY[*]}"
  print_result "Auto-completion with -m flag" 1
fi

# Test 5: Test auto-completion after -m flag
echo "Test 5: Auto-completion after -m flag"

# Set up mock variables for auto-completion
COMP_WORDS=("scripts" "gitlab" "mr-create" "-m" "")
COMP_CWORD=4
cur=""
prev="-m"

# Call the auto-completion function
_scripts_autocomplete

# Check if the result is empty (no suggestions after -m)
if [[ -z "${COMPREPLY[*]}" ]]; then
  print_result "Auto-completion after -m flag" 0
else
  echo "Expected: (empty)"
  echo "Got: ${COMPREPLY[*]}"
  print_result "Auto-completion after -m flag" 1
fi

# Test 6: Test auto-completion after -m and title
echo "Test 6: Auto-completion after -m and title"

# Set up mock variables for auto-completion
COMP_WORDS=("scripts" "gitlab" "mr-create" "-m" "Title" "")
COMP_CWORD=5
cur=""
prev="Title"

# Call the auto-completion function
_scripts_autocomplete

# Check if the result contains branches
if [[ "${COMPREPLY[*]}" == *"feature-branch"* && "${COMPREPLY[*]}" == *"bugfix-branch"* && "${COMPREPLY[*]}" == *"release-branch"* ]]; then
  print_result "Auto-completion after -m and title" 0
else
  echo "Expected: feature-branch bugfix-branch release-branch (in any order)"
  echo "Got: ${COMPREPLY[*]}"
  print_result "Auto-completion after -m and title" 1
fi

# Print summary
echo ""
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ "$TESTS_FAILED" -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi