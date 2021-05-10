declare -i TAP_TEST_NUMBER=0

beforeSuite() {
  [ "$CHECK_SILENT" = true ] && return 0
  local -i testCount=0
  local testFile
  for testFile in "${CHECK_FILES[@]}"; do
    local -i testFileTestCount="$( "$0" --list "$testFile" | wc -l )"
    (( testCount = testCount + testFileTestCount ))
  done
  echo "1..$testCount"
}

afterTest() {
  [ "$CHECK_SILENT" = true ] && return 0
  (( TAP_TEST_NUMBER = TAP_TEST_NUMBER + 1 ))
  printTestLine
  printStdout
  printStderr
  printStacktrace
}

printTestLine() {
  case "$CHECK_STATUS" in
    PASS) echo "ok $TAP_TEST_NUMBER - $CHECK_TEST" ;;
    FAIL) echo "not ok $TAP_TEST_NUMBER - $CHECK_TEST" ;;
  esac
}

printStdout() {
  if [ -n "$CHECK_STDOUT" ] && [ "$CHECK_STATUS" = FAIL -o "$CHECK_VERBOSE" = true ]; then
    echo "# Standard Output"
    echo "$CHECK_STDOUT" | sed 's/^/#   /'
  fi
}

printStderr() {
  if [ -n "$CHECK_STDERR" ] && [ "$CHECK_STATUS" = FAIL -o "$CHECK_VERBOSE" = true ]; then
    echo "# Standard Error"
    echo "$CHECK_STDERR" | sed 's/^/#   /'
  fi
}

printStacktrace() {
  if [ -n "$CHECK_LAST_SOURCE" ] && [ "$CHECK_STATUS" = FAIL ]; then
    echo "# Stacktrace"
    echo "#   $CHECK_LAST_SOURCE:$CHECK_LAST_LINENO $CHECK_LAST_FUNCNAME"
    [ -n "$CHECK_LAST_SOURCECODE" ] && echo "#     $CHECK_LAST_SOURCECODE"
  fi
}