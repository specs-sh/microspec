---
title: ""
---

# `$ microspec`

> _The smallest, TAP-compliant, Mac-compatible, Bash test framework! (30 LOC) (2.79KB)_

---

<script src="https://kit.fontawesome.com/319dabc23d.js" crossorigin="anonymous"></script>

## <i class="fad fa-download"></i> Install

Download the [latest version](https://github.com/specs-sh/microspec/archive/v1.2.0.tar.gz) by clicking one of the download links above or:

```sh
curl -o- https://micro.specs.sh/install.sh | bash
```

## <i class="fad fa-pencil-alt"></i> Write Test

```sh
setup()    { echo "Hello from setup.";    }
teardown() { echo "Hello from teardown."; }

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

```

## <i class="fad fa-terminal"></i> Run

<img src="/assets/images/screenshot_microspec_dark.png" style="max-height: 350px;" />

## <i class="fad fa-terminal"></i> Run (TAP)

```python
./microtap example.spec.sh

1..2
not ok - test.shouldFail
# Standard Output:
#  Hello from setup.
#  STDOUT from shouldFail
#  Hello from teardown.
# Standard Error:
#  STDERR from shouldFail
# Stacktrace:
#   example.spec.sh:13 test.shouldFail
#    (( 1 == 0 )) # <-- this fails so the test fails
ok - test.shouldPass
```

## <i class="fad fa-books"></i> Documentation

## Test Syntax

A **test** is any function starting with _"test"_ or _"spec"_:

```sh
testHelloWorld() {
  : # write your test commands here
  [ "Hello" = "Hello" ]
}

specGoodnightMoon() {
  : # write your test commands here
  [ "Goodnight" = "Goodnight" ]
}
```

## Passing or Failing Tests

A test will **fail** if any of the following conditions are met:

1. The test function returns a non-zero exit code, e.g. `return 1`
  > Note: if the last command in the function returns non-zero, it will fail
1. The test function exits with a non-zero exit code, e.g. `exit 1`
1. **Any statement** in the function returns a non-zero exit code

```sh
testHelloWorld() {
  [ "Hello" = "World" ] # <--- This will fail the test and stop execution.
  (( 1 == 1 ))          # <--- This command will not be run.
}
```

> ℹ️ **Note:** _To learn more, look into the `set -e` (which is used in `microspec` to fail tests)_

## Setup and Teardown

Any function starting with _"setup"_ or _"before"_ is run **_before each test_**:

```sh
setupList() { # <--- could alternatively be named 'before' or 'beforeList' etc
  list=( a b c )
}

testList() {
  (( ${#list[@]} == 3 ))
}
```

Any function starting with _"teardown"_ or _"before"_ is run **_after each test_**:

```sh
before() { # <--- could alternatively be named 'setup' or 'setupTempDir' etc
  tempDir="$( mktemp -d )"
}

after() { # <--- could alternatively be named 'teardown' or 'teardownTempDir' etc
  [ -d "$tempDir" ] && rm -r "$tempDir"
}

testSomething() { # <--- could alternatively be named 'specSomething' etc
  echo "Hello, world!" > "$tempDir/hello"
  [ "Hello, world!" = "$( cat "$tempDir/hello" )" ]  
}
```

> ℹ️ **Note:** _Teardown functions are run even if the test fails._

## <i class="fab fa-apple"></i> Mac OS X Support

Mac OS uses a _very old_ version of Bash: `Bash 3.5.57` (_release in 2006_)

`microspec` was _specifically_ authored to make sure this old version was supported.

`microspec` supports all Bash versions from `3.2.57` to `5.0` (_latest_)

# <i class="fad fa-search-plus"></i> The Code

For those who are interested, here are the 30 lines of code for `microspec`:

```sh
#! /usr/bin/env bash
MICROSPEC_VERSION=1.2.0; [ "$1" = --version ] && { echo "microspec version $MICROSPEC_VERSION"; exit 0; }
[ "$1" = --list ] && [ -f "$2" ] && { source "$2"; if declare -pF | awk '{print $3}' | grep -i '^test\|^spec' 2>/dev/null; then exit 0; else exit $?; fi; }
runAll() { if [ -z "${1:-}" ]; then return 0; fi; if __spec__functions="$( declare -pF | awk '{print $3}' | grep -i "$1" 2>/dev/null )"; then for __spec__fn in $__spec__functions; do $__spec__fn; done; fi; }
recordCmd() { spec_return=$?; if (( $1 == 0 )) && [ "$2" != "$0" ]; then if [ -z "$__spec__testDone" ]; then CMD_INFO=("${@:1}"); fi; fi; return $spec_return; }
[ "$1" = --run ] && [ -f "$2" ] && [ -n "$3" ] && { source "$2"; set -eET; trap : ERR
  trap 'CMD_INFO[0]=$?; __spec__testDone=true; runAll "^teardown\|^after"; declare -p CMD_INFO' EXIT
  trap 'recordCmd $? "${BASH_SOURCE[0]}" "$LINENO" "${FUNCNAME[0]}" "$BASH_COMMAND";' DEBUG; 
  runAll "^setup\|^before"; "$3"; exit $?; }
for SPEC_FILE; do echo -e "[\e[36m$SPEC_FILE\e[0m]"; declare -i PASSED=0; declare -i FAILED=0
  if [ -f "$SPEC_FILE" ]; then
    for SPEC_TEST in $("$0" --list "$SPEC_FILE" 2>/dev/null); do
      SPEC_TEST_OUTPUT="$({ STDERR="$({ STDOUT="$( "$0" --run "$SPEC_FILE" "$SPEC_TEST" )"; } 2>&1; declare -i EXITCODE=$?; declare -p STDOUT >&2; declare -p EXITCODE >&2; exit $EXITCODE;)"; declare -p STDERR; exit 0; } 2>&1 )"
      eval "$SPEC_TEST_OUTPUT";
      [[ "$STDOUT" =~ .*(declare[[:space:]]-a[[:space:]]CMD_INFO=[\']?\(.*)$ ]] && __spec_lastCmdText__="${BASH_REMATCH[1]}"
      [ -n "$__spec_lastCmdText__" ] && { eval "$__spec_lastCmdText__"; STDOUT="${STDOUT%"$__spec_lastCmdText__"}"; STDOUT="${STDOUT%$'\n'}"; }
      (( EXITCODE == 0 )) && { (( PASSED++ )); echo -e "  [\e[32mPASS\e[0m] $SPEC_TEST"; } || { (( FAILED++ )); echo -e "  [\e[31mFAIL\e[0m] $SPEC_TEST"; }
      (( EXITCODE != 0 )) || [ "$VERBOSE" = true ] && {
        [ -n "$STDOUT" ] && { echo -e "    [\e[34mStandard Output\e[0m]"; echo -e "\e[39;2m$( echo -e "$STDOUT" | sed 's/^/      /' )\e[0m"; }
        [ -n "$STDERR" ] && { echo -e "    [\e[31mStandard Error\e[0m]"; echo -e "\e[39;2m$( echo -e "$STDERR" | sed 's/^/      /' )\e[0m"; }
        (( ${#CMD_INFO[@]} > 2 )) && { (( EXITCODE != 0 )) || [ "$STACKTRACE" = true ]; } && {
          echo -e "    [\e[33mStacktrace\e[0m]"; echo -e "      \e[34m${CMD_INFO[1]}\e[0m:\e[34m${CMD_INFO[2]} ${CMD_INFO[3]}";
          [ -f "${CMD_INFO[1]}" ] && echo -e "\e[33;2m$( sed "${CMD_INFO[2]}q;d" "${CMD_INFO[1]}" | sed "s/^ *//g" | sed "s/^/        /" )\e[0m";
        }
      }
    done
  fi
  (( FAILED > 0 )) && echo -e "\e[31;1m" || echo -e "\e[32m"; echo -e "$PASSED Passed, $FAILED Failed"; printf '\e[0m%s' ''
  (( FAILED > 0 )) && exit 1 || exit 0
done
```

Some interesting things to note for Bash geeks:

- Every test is run in its own subprocess (_with_ `set -eET`)
- _No_ temporary files are used (_we get STDOUT/STDERR separately a different way_)
- The subprocess communicates its result back to the parent using `declare -p`
  - The subprocess defines variables and uses `declare -p VAR` to safely serialize the variable
  - Then the parent process `eval`'s the provided _safely_ serialized string
- `DEBUG` trap is used to get the command that failed (_`ERR` sees the command **after** the failing one_)
  - Every command is watched so, when `ERR` and `EXIT` are triggered, we have the command that failed 
- `ERR` trap is registered but does nothing. Simply being registered lets `ERR` exit and trigger `EXIT`
- `EXIT` trap is used to run teardown functions and uses `declare -p` to communicate back to the parent
- `microspec`, itself, does not run with `set -e` or `set -u` (_it would add extra needless code_)
- _It was really fun to make!_