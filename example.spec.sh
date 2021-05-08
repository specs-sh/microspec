# set -eE

test.shouldPass() {
  set -eE
  if echo HELLO | grep WORLD
  then
    : # Who cares? It's a conditional
  fi

  # result="$( ls /this/doesnt/exist )"
  result="$( ls /this/doesnt/exist )" || :
  # exit 2

  echo "STDOUT from shouldPass"
  echo "STDERR from shouldPass" >&2
  (( 1 == 1 ))
}

test.shouldFail() {
  set -eE
  echo "STDOUT from shouldFail"
  echo "STDERR from shouldFail" >&2
  (( 1 == 0 )) # <-- this fails so the test fails
  (( 1 == 1 )) # <-- even though the final result passes
}