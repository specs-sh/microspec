thisHelperFails() {
  result="$( ls this/path/doesnt/exist )"
}

test.ShouldFail.the.line.of.code.shown.should.be.from.the.helper.function() {
  thisHelperFails # <-- this should be the stacktrace
  echo "This should not run"
}