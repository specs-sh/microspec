test.runsMainExampleOK() {
  local result="$( CHECK_COLOR=false ./check example.spec.sh 2>&1 )" && : || :
  echo "$result"
  [[ "$result" = *"[PASS] test.shouldPass"* ]]
  [[ "$result" = *"[FAIL] test.shouldFail"* ]]
  [[ "$result" = *"example.spec.sh:13 test.shouldFail"* ]]
  [[ "$result" = *"(( 1 == 0 )) # <-- this fails so the test fails"* ]]
  [[ "$result" = *"1 Test(s) Failed"* ]]
}