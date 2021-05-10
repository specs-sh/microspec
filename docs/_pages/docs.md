---
title: ""
# layout: collection
# collection: docs
# entries_layout: grid
# classes: wide
permalink: /docs
author_profile: true
show_links: true
show_download_button: true
always_show_sidebar: true
sidebar:
  nav: sidebar
# toc: true
---

[![Mac (BASH 3.2)](https://github.com/specs-sh/check/workflows/Mac%20(BASH%203.2)/badge.svg)](https://github.com/specs-sh/check/actions?query=workflow%3A%22Mac+%28BASH+3.2%29%22) [![BASH 4.0](https://github.com/specs-sh/check/workflows/BASH%204.0/badge.svg)](https://github.com/specs-sh/check/actions?query=workflow%3A%22BASH+4.0%22) [![BASH 4.4](https://github.com/specs-sh/check/workflows/BASH%204.4/badge.svg)](https://github.com/specs-sh/check/actions?query=workflow%3A%22BASH+4.4%22) [![BASH 5.0](https://github.com/specs-sh/check/workflows/BASH%205.0/badge.svg)](https://github.com/specs-sh/check/actions?query=workflow%3A%22BASH+5.0%22)

# <i class="fad fa-books"></i> `check` Documentation

## <i class="fas fa-cog"></i> Install

```sh
curl -o- https://check.shellbox.sh/install.sh | bash
```

Or manually [download](https://github.com/specs-sh/check/releases) and extract the latest version from GitHub ([download](https://github.com/specs-sh/check/releases)).

The release contains a single `check` executable file which can be run directly  
or added to your `PATH` to run from anywhere on your system.

```sh
./check --version
check version 1.2.0
```

## <i class="fad fa-pencil"></i> Write test

Once you have `check` downloaded and have verified you can run it (`check --version`),
create your first test!

Create a file named `myFirstTest.test.sh` and add the following content:

```sh
test.helloWorld() {
  result="$( echo "Hello, world!" )"
  [ "Hello, world!" = "$result" ]
}
```

## <i class="far fa-running"></i> Run test

Now run `myFirstTest.test.sh` using `check` by running:

```sh
./check myFirstTest.test.sh
```

You should see the following output:

```sh
[myFirstTest.sh]
  [PASS] test.helloWorld

1 Test(s) Passed
```

<img src="/assets/images/screenshot_myFirstTest.png" align=left style="max-height: 120px;" />
<img src="/assets/images/screenshot_myFirstTest_light.png" align=left style="max-height: 120px;" />
<br style="clear: left;" />

> 💡 **Tip:** If you have trouble seeing the output, run `./check --no-color myFirstTest.test.sh` which will output the test results without color.
>
> You can learn about customizing colors in the section: <a href="#-customize-colors"><i class="fad fa-palette"></i> Customize Colors</a>

## <i class="fad fa-language"></i> Test syntax

Tests are implemented as BASH functions.

Functions which start with `test`, `@test`, `spec`, or `@spec` are considered tests.

> 💡 **Tip:** You can customize this using the [`--test-pattern`](#--test-pattern) option.

#### Passing and Failing Tests

When tests are run, there are a few conditions which mark a test as "_failing_":

- A test fails if the function returns a non-zero exit code, e.g. `return 1`
- A test fails if the function exits with a non-zero exit code, e.g. `exit 1`
- A test fails if the function runs _any statement_ which returns a non-zero exit code,  
  e.g. `(( 1 == 0 ))` or `output="$( echo "hello" | grep this-wont-be-found )"`

If none of these conditions are met, then a test will be marked as "_passing_".

When a failure condition is triggered, the triggering line of code is noted
and will be displayed along with the file path and line of code as a "_Stacktrace_".

#### Example

To view an example of a failing test, update `myFirstTest.test.sh` with the following:

```sh
test.helloWorld() {
  result="$( echo "Hello, world" | grep Foo )" # <-- grep will fail here
  [ "Hello, world!" = "$result" ]
}
```

Now run the test again using `./check myFirstTest.test.sh`:

```sh
./check myFirstTest.test.sh
```

You should see the following output:

```sh
[myFirstTest.sh]
  [FAIL] test.helloWorld
    [Stacktrace]
      myFirstTest.sh:2 test.helloWorld
        result="$( echo "Hello, world" | grep Foo )" # <-- grep will fail here

1 Test(s) Failed
```

The test now fails and a "_Stacktrace_" is displayed showing the offending line of code.

> #### Why does this fail?
> 
> `echo "Hello, world" | grep Foo` fails because `Foo` was not found by `grep`.
> 
> You can try this yourself in a BASH terminal:
>
> ```sh
> echo "Hello, world" | grep Foo
> echo $? # <--- this prints the exit code of the previous command (grep)
> ```
>
> _Any_ failing command triggers a failure, read more below in [About `set -e`](#-about-set--e)


## <i class="fad fa-arrows-v"></i> Setup and Teardown

Use `setup` and `teardown` functions to run a code before or after every test.

```sh
setup() {
  echo "Hello from setup" # This will be run once before each test
}
teardown() {
  echo "Hello from teardown" # This will be run once after each test
}
testOne() { echo "Hello from test 1"; }
testTwo() { echo "Hello from test 2"; }
```

Running the above example will result in the following output:

```sh
./check myExample.spec.sh

[myExample.spec.sh]
  [PASS] testTwo
  [PASS] testOne
```

No output is displayed because each test passes.

Run `check` again, this time passing the `-v` or `--verbose` option:

```sh
./check myExample.spec.sh -v

[foo.spec.sh]
  [PASS] testOne
    [Standard Output]
      Hello from setup
      Hello from test 1
      Hello from teardown
  [PASS] testTwo
    [Standard Output]
      Hello from setup
      Hello from test 2
      Hello from teardown
```

The `setup` and `teardown` functions were run `before` and `after` each test.

> 💡 **Tip**: you can define multiple setup and teardown functions.  
>
> Any function beginning with `setup` or `before` is run before each test  
> and any function beginning with `teardown` or `after` is run after each test.
>
> This is useful if you want to `source` a helper file to use across all of
> your tests, you can `setup.global` and `teardown.global` functions.
>
> Use [`--setup-pattern`](#--setup-patern) or [`--teardown-pattern`](#--teardow-pattern) to change function names.

## <i class="fad fa-volcano"></i> About <code>set -e</code>

By default, test files are run with the following BASH options configured:

- `set -o errexit` (`set -e`)
- `set -o errtrace` (`set -E`)
- `set -o functrace` (`set -T`)

The `errexit` option (_or `set -e` for short_) is what allows us to immediately
fail a test whenever any statement is executed which returns a non-zero exit code.

```sh
test.thisTestFails() {
  echo "STDOUT from shouldFail"
  echo "STDERR from shouldFail" >&2
  (( 1 == 0 )) # <-- This line fails so the whole test fails
  (( 1 == 1 )) # <-- even though the final result passes.
}
```

### Should I use `set -e`?

Yes, you probably should. Unless you are really sure what you're doing.

Using `set -e` is common when testing shell scripts, but it can be a nuisance.

Consider the following example:

```sh
test.myTest() {
  result="$( command that may fail )" # <--- if this fails, the test fails
  [[ "$result" = *"Some expected text"* ]]
}
```

If you are testing a command which _may fail_, the above must be rewritten as:

```sh
test.myTest() {
  if result="$( command that may fail )" # <--- using 'if' allows it to fail OK
  then
    [[ "$result" = *"Some expected text"* ]]
  else
    [[ "$result" = *"Some expected text"* ]]
  fi
}
```

Or you might sometimes see code like this:

```sh
test.myTest() {
  if result="$( command that may fail )"; then :; fi # <--- Hacky but works
  [[ "$result" = *"Some expected text"* ]]
}
```

### Disabling `set -e`

You may disable the default `set -e` behavior by running `check` with `--no-set-e`.

Without this feature enabled, tests will fail in one of these cases:

- A test fails if the function returns a non-zero exit code, e.g. `return 1`
- A test fails if the function exits with a non-zero exit code, e.g. `exit 1`

> 💡 **Tip:** Add `set -u` (_aka_ `set -o nounset`) to the top of each test script.  
> When `set -u` is set, tests fail when attempting to use any undefined variable.



---

# <i class="fad fa-heart"></i> Related Projects

## <i class="fad fa-terminal"></i> <code>run</code>
## <i class="fad fa-vial"></i> <code>assert</code>
## <i class="fad fa-flask"></i> <code>expect</code>

# <i class="fad fa-terminal"></i> Options

This section documents options which can be passed to the `check` command.

## <code>&lt;file&gt; &lt;directory&gt;</code>

You can pass any files or directories to `check`.

Directories are searched recursively for `*.test.sh` and `*.spec.sh` files.

When run without any files or directories specified, `check` searches the
current directory recursively for `*.test.sh` and `*.spec.sh` files.

## <code>-f / --filter</code>

To run only test functions matching a provided pattern, pass `-f [pattern]`

```sh
check --filter hello    # Only run tests with hello in the name (case-insensitive)
check --filter ^testDog # Only run tests which start with 'testDog'
check --filter 'Dog$'   # Only run tests which end with 'Dog'
```

> You can alternatively set `CHECK_FILTER='pattern'`

## <code>-v / --verbose</code>

By default, a test's STDOUT and STDERR is only printed if the test fails.

Pass the `-v`/`--verbose` option to print STDOUT and STDERR for all tests.

> You can alternatively set `CHECK_VERBOSE=true`

## <code>-q / --quiet</code>

Providing `-q` or `--quiet` will run `check` without printing any output.

To determine success or failure, check the `$?` exit code of `check`.

```sh
if check -q myTest.test.sh
then
  echo "The tests passed"
else
  echo "The tests failed"
fi
```

> You can alternatively set `CHECK_SILENT=true`

## <code>-c / --config</code>

To provide `check` configuration in a file, either:

- Create a file named `.checkrc` in the directory you run `check` from
- Provide the path to a file using `-c [filepath]` or `--config [filepath]`

Configuration files are loaded via `source` right before running the test suite.

They can be used to set variables, e.g. instead of passing `--xxx` options.

#### Example `.checkrc`

```
# .checkrc
CHECK_COLOR=false
CHECK_FILE_PATTERN='.verify.sh$'
CHECK_TEST_PATTERN='^verify'
```

> You can alternatively set `CHECK_CONFIG="path/to/config.sh"`

Configuration files can be used to subscribe to `check` ["Hooks" (read more below)](#-test-hooks).

## <code>-s / --set</code>

By default, `check` runs tests with the following BASH options:

```sh
set -eET
```

You can override this by providing your own set variables:

```sh
check --set "eETuo pipefail" myTest.test.sh
```

> Note: if you do not provide `T` you will not get any _"Stacktrace"_ output.

> Note: if you do not provide `e` tests will not fail when any statement fails.

> You can alternatively set `CHECK_SET_OPTS="eETuo pipefail"`

## <code>--no-set / --no-set-e</code>

If you prefer to run tests without _any_ of the default `check` `set` variables:

```sh
check --no-set myTest.test.sh
```

This won't `set` anything on your behalf (_you could add `set -e` to your own test file_).

To keep all `check` functionality intact but disable the BASH `set -e` behavior, use:

```sh
check --no-set-e myTest.test.sh
```

This will keep features such as _"Stacktrace"_ output working without [`set -e` behavior](#-about-set--e).

> You can alternatively set `CHECK_SET_OPTS=NONE`

## <code>--color / --no-color</code>

By default, `check` provides its own color output format.

To disable color output, run:

```sh
check --no-color myTest.test.sh
```

> You can alternatively set `CHECK_COLOR=true` or `CHECK_COLOR=false`

## <code>--random / --no-random</code>

By default, `check` runs files and tests in a random order.

To disable this, run:

```sh
check --no-random myTest.test.sh
```

> You can alternatively set `CHECK_RANDOM=true` or `CHECK_RANDOM=false`

## <code>--formatter</code>

The provided file will be loaded via `source`.

```sh
check --formatter myFormatter.sh myTest.test.sh
```

> You can alternatively set `CHECK_FORMATTER="path/to/formatter.sh"`

See <a href="#-writing-formatters"><i class="fad fa-print"></i> Write Formatters</a> below for details.

## <code>--file-pattern</code>

By default, `check` searches for `*.test.sh` and `*.spec.sh` files in directories.

This can be easily overridden using the `--file-pattern` option:

```sh
check --file-pattern verify.sh    # Run any files containing 'verify.sh'
check --file-pattern 'verify.sh$' # Run any files ending with 'verify.sh'
```

> You can alternatively set `CHECK_FILE_PATTERN="pattern1\|pattern2"`

> Note: patterns are matched using `grep` and are not case-sensitive.

## <code>--test-pattern</code>

By default, test functions must start with `test`, `@test`, `spec`, or `@spec`

This can be easily overriden using the `--test-pattern` option:

```sh
check --test-pattern "verify"  # Function names containing 'verify'
check --test-pattern "^verify" # Function names starting with 'verify'
check --test-pattern "^verify\|^assert" # Multiple patterns example
```

Then you can write your tests using your own custom function name format:

```sh
verifyFactOne() {
  # ...
}

verifyFactTwo() {
  # ...
}
```

> You can alternatively set `CHECK_TEST_PATTERN="pattern1\|pattern2"`

> Note: patterns are matched using `grep` and are not case-sensitive.

## <code>--setup-pattern</code>
## <code>--teardown-pattern</code>

---
# <i class="fad fa-cog"></i> Customization
## <i class="fad fa-feather-alt"></i> Customize Test Syntax
## <i class="fad fa-fish"></i> Test Hooks
## <i class="fad fa-print"></i> Write Formatters
## <i class="fad fa-palette"></i> Customize Colors
