# 🧫 MicroSpec

> BASH Testing Framework _so tiny you can copy/paste it into your test files!_

---

## 8 Lines of Code

Just put this at the bottom of any test file:

```sh
test.shouldPass() {
  (( 42 == 42 ))
}

test.shouldFail() {
  (( 1 == 0 ))
}

# Copy/paste the 8 lines of code below:
for testFn in $( declare -pF | awk '{ print $3 }' | grep ^test | sort -R ); do
  if output="$( set -eE; $testFn 2>&1 )"; then
    echo -e "[\e[32mPASS\e[0m] $testFn"; [ "$VERBOSE" = true ] && printf '%s\n%s\n' Output: "$output"
  else
    echo -e "[\e[31mFAIL\e[0m] $testFn"; anyFailed=$(( anyFailed = anyFailed + 1 )); printf '%s\n%s\n' Output: "$output"
  fi
done
[ -n "$anyFailed" ] && { echo "$anyFailed test(s) failed" >&2; exit 1; }
```

### Have multiple test files?

Copy/paste the code into a `runTests.sh` file and `source` it from your tests:

```sh
test.shouldPass() {
  (( 42 == 42 ))
}

test.shouldFail() {
  (( 1 == 0 ))
}

source runTests.sh
```

> You can copy/paste the `runTests.sh` file here in GitHub is you would like.

### That's it.

Here is the output of running the `example.spec.sh` file here in GitHub:

![Screenshot of MicroSpec output](screenshot.png)