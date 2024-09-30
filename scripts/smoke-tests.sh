#!/bin/bash

# Base URL of the application
BASE_URL="http://localhost:8080"

# Function to test an endpoint
# Arguments:
#   $1 - Endpoint to test (e.g., "/")
#   $2 - Expected HTTP status code (e.g., 200)
#   $3 - Expected response body (e.g., "WELCOME")
test_endpoint() {
  local endpoint=$1
  local expected_status=$2
  local expected_body=$3

  # Make a request to the endpoint and capture the HTTP status code and response body
  response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL$endpoint)
  body=$(curl -s $BASE_URL$endpoint)

  # Check if the response matches the expected status code and body
  if [ "$response" -eq "$expected_status" ] && [ "$body" == "$expected_body" ]; then
    echo "Test passed for $endpoint"
  else
    echo "Test failed for $endpoint"
    echo "Expected status: $expected_status, Got: $response"
    echo "Expected body: $expected_body, Got: $body"
    exit 1
  fi
}

# Test the root endpoint
# Expected status: 200 OK
# Expected body: "WELCOME"
test_endpoint "/" 200 "WELCOME"

# Test the /resource-created endpoint
# Expected status: 201 Created
# Expected body: "CREATED"
test_endpoint "/resource-created" 201 "CREATED"

# Test the /resource-accepted endpoint
# Expected status: 202 Accepted
# Expected body: "ACCEPTED"
test_endpoint "/resource-accepted" 202 "ACCEPTED"

# If all tests pass, print a success message
echo "All smoke tests passed!"
