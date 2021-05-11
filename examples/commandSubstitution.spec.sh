test.ShouldFail.getting.command.output.fails.unless.in.a.conditional() {
  result="$( ls /this/folder/doesnt/exist 2>&1 )"
  echo "This should not run" # <--- never runs
}

test.ShouldPass.getting.command.output.fails.unless.in.a.conditional() {
  if result="$( ls /this/folder/doesnt/exist 2>&1 )"
  then
    echo "This should not run" # <--- never runs
  else
    echo "This should run" # <--- should run!
  fi
}