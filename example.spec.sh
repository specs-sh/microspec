#! /usr/bin/env bash

test.shouldPass() {
  echo "STDOUT from shouldPass"
  echo "STDERR from shouldPass" >&2
  (( 1 == 1 ))
}

test.shouldFail() {
  echo "STDOUT from shouldFail"
  echo "STDERR from shouldFail" >&2
  (( 1 == 0 )) # <-- this fails so the test fails
  (( 1 == 1 )) # <-- even though the final result passes
}

# Copy/paste the 8 lines of code below:
testTrap='echo "Stacktrace:"; for ((i=0;i<${#BASH_SOURCE[@]};i++)); do echo "${BASH_SOURCE[i]}:${LINENO[i]} ${FUNCNAME[i]}()\n$( sed "${LINENO[i]}q;d" "${BASH_SOURCE[i]}" | sed "s/^ *//g" | sed "s/^/    /" )"; done'
for testFn in $( declare -pF | awk '{ print $3 }' | grep ^test\|^spec | sort -R ); do
  output="$( trap "$testTrap" ERR; [ -z "${BEFORE_TEST+x}" ] && set -eE || eval "$BEFORE_TEST"; $testFn 2>&1 )"
  case $? in
    0) echo -e "[\e[32mPASS\e[0m] $testFn"; [ "$VERBOSE" = true ] && printf '  %s\n%s\n' Output: "$( echo -e "$output" | sed 's/^/    /' )" ;;
    *) echo -e "[\e[31mFAIL\e[0m] $testFn"; anyFailed=$(( anyFailed = anyFailed + 1 )); printf '  %s\n%s\n' Output: "$( echo -e "$output" | sed 's/^/    /' )" ;;
  esac
done; [ -n "$anyFailed" ] && { echo "$anyFailed test(s) failed" >&2; exit 1; }