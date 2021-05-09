test.runsMainExampleOK() {
  local result="$( ./check example.spec.sh 2>&1 )" && : || :
  result="$( removeColorCodes "$result" )"
  [[ "$result" = *"[PASS] test.shouldPass"* ]]
  [[ "$result" = *"[FAIL] test.shouldFail"* ]]
  [[ "$result" = *"example.spec.sh:10 test.shouldFail"* ]]
  [[ "$result" = *"(( 1 == 0 )) # <-- this fails so the test fails"* ]]
  [[ "$result" = *"1 Test(s) Failed"* ]]
}

removeColorCodes() {
  echo "$1" | sed -r "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g"
}