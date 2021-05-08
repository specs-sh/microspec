test.runsMainExampleOK() {
  echo HI
  ls
}

removeColorCodes() {
  echo "$1" | sed -r "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g"
}