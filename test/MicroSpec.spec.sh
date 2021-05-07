#! /usr/bin/env bash

test.runsMainExampleOK() {
  if result="$( ./example.spec.sh 2>&1 )"
  then
    return 1 # The test is supposed to fail
  else
    result="$( removeColorCodes "$result" )"
    echo "Example Tests Result: $result"
    [[ "$result" = *"[PASS] test.shouldPass"* ]]
    [[ "$result" = *"[FAIL] test.shouldFail"* ]]
    [[ "$result" = *"./example.spec.sh:12 test.shouldFail()"* ]]
    [[ "$result" = *"(( 1 == 0 )) # <-- this fails so the test fails"* ]]
    [[ "$result" = *"1 test(s) failed"* ]]
  fi
}

removeColorCodes() {
  echo "$1" | sed -r "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g"
}

source runTests.sh