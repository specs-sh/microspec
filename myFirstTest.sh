test.helloWorld() {
  result="$( echo "Hello, world!" | grep FooBar )" # <-- grep will fail here
  [ "Hello, world!" = "$result" ]
  return 1
  return 0
}