test.TAP.formatter.works() {
  local result="$( ./check example.spec.sh --formatter formatters/TAP.sh 2>&1 )" && : || :
  echo "$result"
  # [[ "$result" = *"[PASS] test.shouldPass"* ]]
  # [[ "$result" = *"[FAIL] test.shouldFail"* ]]
  # [[ "$result" = *"example.spec.sh:13 test.shouldFail"* ]]
  # [[ "$result" = *"(( 1 == 0 )) # <-- this fails so the test fails"* ]]
  # [[ "$result" = *"1 Test(s) Failed"* ]]
}