test.shouldPass() {
  echo "STDOUT from shouldPass"
  echo "STDERR from shouldPass" >&2

  if echo HELLO | grep WORLD
  then
    : # Who cares? It's a conditional
  fi

  echo -e "\e[32mCOLORS\e[0m"

  # result="$( ls /this/doesnt/exist )"
  if result="$( ls /this/doesnt/exist )"
  then
    echo Cool
  fi
  # exit 2

  (( 1 == 1 ))
}

test.shouldFail() {
  shopt -qo errexit && echo "ERREXIT IS SET" || echo "NOPE ITS OFF"
  echo "STDOUT from shouldFail"
  echo "STDERR from shouldFail" >&2
  (( 1 == 0 )) # <-- this fails so the test fails
  (( 1 == 1 )) # <-- even though the final result passes
  echo "Output which should not be seen from shouldFail"
}

# foo() {
#   echo FOO
#   echo HI | grep world
# }