#! /usr/bin/env bash

test.shouldPass() {
  echo "STDOUT from shouldPass"
  echo "STDERR from shouldPass" >&2
  (( 1 == 1 ))
}

test.shouldFail() {
  echo "STDOUT from shouldFail"
  echo "STDERR from shouldFail" >&2
  (( 1 == 0 ))
}

for testFn in $( declare -pF | awk '{ print $3 }' | grep ^test | sort -R ); do
  if output="$( set -eE; $testFn 2>&1 )"; then
    echo -e "[\e[32mPASS\e[0m] $testFn"; [ "$VERBOSE" = true ] && printf '%s\n%s\n' Output: "$output"
  else
    echo -e "[\e[31mFAIL\e[0m] $testFn"; anyFailed=$(( anyFailed = anyFailed + 1 )); printf '%s\n%s\n' Output: "$output"
  fi
done
[ -n "$anyFailed" ] && { echo "$anyFailed test(s) failed" >&2; exit 1; }