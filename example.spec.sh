#! /usr/bin/env bash

# myDebug() {
#   foo=$?
#   echo "MY DEBUG called with $# arguments: $* -- return value: $foo - $BASH_COMMAND"
# }

# trap myDebug DEBUG

# # trap 'echo BOOM' ERR

# # set -e

# ls /foobar

# (( 1 == 0 ))



test.shouldPass() {
  echo "STDOUT from shouldPass"
  echo "STDERR from shouldPass" >&2
  (( 1 == 1 ))
}

test.shouldFail() {
  echo "STDOUT from shouldFail?"
  echo "STDERR from shouldFail?" >&2
  (( 1 == 0 )) # <-- this fails so the test fails
  (( 1 == 1 )) # <-- even though the final result passes
}

# # Copy/paste the 8 lines of code below:
# # TODO

# Alternatively, simply source runTests.sh
source runTests.sh