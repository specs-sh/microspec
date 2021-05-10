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

<!-- # <i class="fad fa-heart"></i> Related Projects
## <i class="fad fa-terminal"></i> <code>run</code>
## <i class="fad fa-vial"></i> <code>assert</code>
## <i class="fad fa-flask"></i> <code>expect</code> -->

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
export CHECK_COLOR=false
export CHECK_FILE_PATTERN='.verify.sh$'
export CHECK_TEST_PATTERN='^verify'
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

## <code>-l / --list</code>

List all of the test functions in the provided file:

```sh
check myTest.test.sh
testOne
testTwo
```

> Note: this utility function is only available for _test names and_
> there is not currently a command to print _setup_ or _teardown_ functions.

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

> You can alternatively set `CHECK_RANDOM="command"` used to randomize text.  
> To disable random using a variable, set `CHECK_RANDOM="grep ."`  
> Defaults to `CHECK_RANDOM=shuf`. The command is piped to, e.g. `... | shuf`

## <code>--formatter</code>

The provided file will be loaded via `source`.

```sh
check --formatter myFormatter.sh myTest.test.sh
```

> You can alternatively set `CHECK_FORMATTER="path/to/formatter.sh"`

See <a href="#-writing-formatters"><i class="fad fa-print"></i> Write Formatters</a> below for details.

## <code>--file-pattern</code>

By default, `check` searches for `*.test.sh` and `*.spec.sh` files in directories.

This can be easily customized using the `--file-pattern` option:

```sh
check --file-pattern verify.sh    # Run any files containing 'verify.sh'
check --file-pattern 'verify.sh$' # Run any files ending with 'verify.sh'
```

> You can alternatively set `CHECK_FILE_PATTERN="pattern1\|pattern2"`

> Note: patterns are matched using `grep` and are not case-sensitive.

## <code>--test-pattern</code>

By default, test functions must start with `test`, `@test`, `spec`, or `@spec`

This can be easily customized using the `--test-pattern` option:

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

By default, setup functions must start with `setup` or `before`.

This can be easily customized using the `--setup-pattern` option:

```sh
check --setup-pattern ^prepare # Function names starting with 'prepare'
```

Then you can write your tests using your custom setup syntax:

```sh
prepare() {
  # Setup code goes here
}

testOne() {
  # ...
}
```

> You can alternatively set `CHECK_SETUP_PATTERN="pattern1\|pattern2"`

> Note: patterns are matched using `grep` and are not case-sensitive.

## <code>--teardown-pattern</code>

By default, teardown functions must start with `teardown` or `after`.

This can be easily customized using the `--teardown-pattern` option:

```sh
check --teardown-pattern ^cleanup # Function names starting with 'cleanup'
```

Then you can write your tests using your custom teardown syntax:

```sh
cleanup() {
  # Teardown code goes here
}

testOne() {
  # ...
}
```

> You can alternatively set `CHECK_TEARDOWN_PATTERN="pattern1\|pattern2"`

> Note: patterns are matched using `grep` and are not case-sensitive.

---
# <i class="fad fa-cog"></i> Customization

This section covers various ways you can customize `check` to suit your own needs.

## <i class="fad fa-feather-alt"></i> Customize Test Syntax

The test syntax can be customized using:

| Option | Environment Variable | Description |
|-|-|-|
| [`--file-pattern`](#--file-pattern) | `CHECK_FILE_PATTERN` | _Configure filenames `check` searches for in directories._ |
| [`--test-pattern`](#--test-pattern) | `CHECK_TEST_PATTERN` | _Customize which functions are run as tests_ |
| [`--setup-pattern`](#--setup-pattern) | `CHECK_SETUP_PATTERN` | _Customize which functions are run before each test_ |
| [`--teardown-pattern`](#--teardown-pattern) | `CHECK_TEARDOWN_PATTERN` | _Customize which functions are run after each test_ |

You can combine these to create your own entirely custom testing experience.

> 💡 **Tip:** configure these in a `.checkrc` to define your own syntax

#### Example `.checkrc`

```sh
export CHECK_FILE_PATTERN='\.verify\.sh$' # Files ending with .verify.sh
export CHECK_TEST_PATTERN='^verify'       # Functions starting with 'verify'
export CHECK_SETUP_PATTERN='^prepare'     # Functions starting with 'prepare'
export CHECK_TEARDOWN_PATTERN='^cleanup'  # Functions starting with 'cleanup'
```

With this `.checkrc` file in the directory you run tests from, the following test runs:

```sh
prepare() {
  echo "Hello from before test"
}
cleanup() {
  echo "Hello from after test"
}
verify.OneThing() {
  echo "Verifying one thing..."
  (( 1 == 1 )) # This one should pass
}
verify.SecondThing() {
  echo "Verifying second thing..."
  (( 1 == 0 )) # This one should fail
}
```

```sh
$ ./check

[./myTest.verify.sh]
  [FAIL] verify.SecondThing
    [Standard Output]
      Hello from before test
      Verifying second thing...
      Hello from after test
    [Stacktrace]
      ./myTest.verify.sh:13 verify.SecondThing
        (( 1 == 0 )) # This one should fail
  [PASS] verify.OneThing

1 Test(s) Failed, 1 Test(s) Passed
```

#### Screenshot

<img src="/assets/images/screenshot_customSyntaxOutput.png" style="max-height: 300px; border-radius: 2%; border: 1px solid; border-color: #666 !important;  padding: 10px; display: inline-block;">

## <i class="fad fa-fish"></i> Test Hooks

While `check` runs tests, it calls hook functions if they are defined:

| Function Name | Description | Noteworthy Variables |
|-|-|-|
| `beforeSuite` | _Runs before the entire test suite_ | `CHECK_FILES` |
| `beforeTestFile` | _Runs before each file is run_ | `CHECK_FILE` |
| `beforeTest` | _Runs before each test is run_ | `CHECK_TEST` |
| `afterTest` | _Runs after each test is run_ | `CHECK_RESULT` `CHECK_STDOUT` `CHECK_STDERR` |
| `afterTestFile` | _Runs after each file is run_ | `CHECK_FILE` |
| `afterSuite` | _Runs after entire test suite_ | `CHECK_PASSED` `CHECK_FAILED` |

These functions can be defined in a provided config file or provided formatter.

> Note: if both config _and_ formatter are provided and _both_ subscribe to hooks,
> only hooks in formatter file will fire (_they'll override the config functions_).

### Variables available to hooks

| Variable | Description |
|-|-|
| `CHECK_FILES` | _Array of paths to provided or found test files_ |
| `CHECK_FILE` | _Path to test file currently being run_ |
| `CHECK_TEST` | _Name of test function currently being run_ |
| `CHECK_STATUS` | _The value "PASS" or "FAIL"_ |
| `CHECK_STDOUT` | _Contents of standard output from test function, if any_ |
| `CHECK_STDERR` | _Contents of standard error from test function, if any_ |
| `CHECK_LAST_COMMAND` | _The last command run in test (does not include teardown commands)_ |
| `CHECK_LAST_EXITCODE` | _The exit code of the last command run in test_ |
| `CHECK_LAST_FUNCNAME` | _The function the last command was run in, e.g. the test name_ |
| `CHECK_LAST_SOURCE` | _The file the last command was run in, e.g. the test file_ |
| `CHECK_LAST_LINENO` | _The line number of the last command that was run_ |
| `CHECK_LAST_SOURCECODE` | _The source code of the last command per the `CHECK_LAST_SOURCE` and `CHECK_LAST_LINENO`_ |

> See also: _Variables used for options, e.g. [`CHECK_COLOR`](#--color----no-color) and [`CHECK_VERBOSE`](#-v----verbose)_

Noteworthy variables which your code may want to respect:

| Variable | Description |
|-|-|
| `CHECK_VERBOSE` | _Verbose output, e.g. show STDOUT/STDERR for passing tests_ |
| `CHECK_SILENT` | _The program should not output anything_ |

## <i class="fad fa-print"></i> Write Formatter

Formatters are written using [<i class="fad fa-fish"></i> Test Hooks](#-test-hooks)

1. Create a source code file
2. Define one or more of the following function names:
  - `beforeSuite`
  - `beforeTestFile`
  - `beforeTest`
  - `afterTest`
  - `afterTestFile`
  - `afterSuite`
3. Call `check --formatter path/to/your/formatter.sh`

When `check` is called with a formatter, _none_ of the default output is shown.

Instead, it is your responsibility as a formatter to `echo` and `printf` beautiful things.

### Example Formatter (TAP)

Here is an example formatter which implements the [TAP specification](https://testanything.org/tap-specification.html):

```sh
# The TAP formatter only needs to use these two test hooks:
# - beforeSuite
# - afterTest

declare -i TAP_TEST_NUMBER=0

# Before the test suite runs, TAP tests are supposed to
# print out the total number of tests that will be run.
beforeSuite() {
  [ "$CHECK_SILENT" = true ] && return 0 # <-- respects `check --quiet`
  local -i testCount=0
  local testFile
  # Loop through all of the test files in the CHECK_FILES array:
  for testFile in "${CHECK_FILES[@]}"; do
    # Call `check --list FILE` which prints out the list of test functions and
    # use `wc -l` to total up the number of lines to increment the test count:
    local -i testFileTestCount="$( "$0" --list "$testFile" | wc -l )"
    (( testCount = testCount + testFileTestCount ))
  done
  echo "1..$testCount" # <-- finally print the TAP "plan"
}

afterTest() {
  [ "$CHECK_SILENT" = true ] && return 0  # <-- respects `check --quiet`
  (( TAP_TEST_NUMBER = TAP_TEST_NUMBER + 1 ))
  printTestLine
  printStdout
  printStderr
  printStacktrace
}

# This prints the TAP "test line"
printTestLine() {
  case "$CHECK_STATUS" in
    PASS) echo "ok $TAP_TEST_NUMBER - $CHECK_TEST" ;;
    FAIL) echo "not ok $TAP_TEST_NUMBER - $CHECK_TEST" ;;
  esac
}

# The functions below print TAP "diagnostics"
#
# If a test fails (or the user called `check --verbose`) then
# the test's STDOUT and STDERR is printed out (if present)
#
# Additionally, the Stacktrace is printed for failed tests.
printStdout() {
  if [ -n "$CHECK_STDOUT" ] && [ "$CHECK_STATUS" = FAIL -o "$CHECK_VERBOSE" = true ]; then
    echo "# Standard Output"
    echo "$CHECK_STDOUT" | sed 's/^/#   /'
  fi
}
printStderr() {
  if [ -n "$CHECK_STDERR" ] && [ "$CHECK_STATUS" = FAIL -o "$CHECK_VERBOSE" = true ]; then
    echo "# Standard Error"
    echo "$CHECK_STDERR" | sed 's/^/#   /'
  fi
}
printStacktrace() {
  if [ -n "$CHECK_LAST_SOURCE" ] && [ "$CHECK_STATUS" = FAIL ]; then
    echo "# Stacktrace"
    echo "#   $CHECK_LAST_SOURCE:$CHECK_LAST_LINENO $CHECK_LAST_FUNCNAME"
    [ -n "$CHECK_LAST_SOURCECODE" ] && echo "#     $CHECK_LAST_SOURCECODE"
  fi
}
```

> You can find the above file in the GitHub repository's `formatters/` folder.

Put the above code into a file named `TAP.sh` and try running a test using:

```sh
check --formatter path/to/TAP.sh myTest.test.sh
```

#### Example Output

```sh
1..3
ok 1 - test.runsMainExampleOK
ok 2 - test.shouldPass
not ok 3 - test.shouldFail
# Standard Output
#   Hello from setup.
#   STDOUT from shouldFail
#   Hello from teardown.
# Standard Error
#   STDERR from shouldFail
# Stacktrace
#   ./example.spec.sh:13 test.shouldFail
#     (( 1 == 0 )) # <-- this fails so the test fails
```

## <i class="fad fa-palette"></i> Customize Colors

Finally! The last bit of the documentation is customizing colors 🎨

There are three main ways to customize `check` color output:

 1. Pass `--no-color` to run with color disabled
 2. Implement your own [formatter](#-write-formatter) as [described above](#-write-formatter)
 3. _Configure a bunch of environment variables!_

> [Here](https://misc.flogisoft.com/bash/tip_colors_and_formatting) is a quick reference for ANSI colors (_the color codes `check` uses_):  
> [https://misc.flogisoft.com/bash/tip_colors_and_formatting](https://misc.flogisoft.com/bash/tip_colors_and_formatting)

Here are all of the environment variables you can configure:

| Variable | Default | Description |
|-|-|-|
| `CHECK_COLOR_TEXT` | `39` | _Used for all text not otherwise described below_ |
| `CHECK_COLOR_FILENAME` | `34` | _Used to display the test file path_ |
| `CHECK_COLOR_TESTNAME` | `39` | _Used to display the test file path_ |
| `CHECK_COLOR_FAIL` | `31` | _Used to display 'FAIL'_ |
| `CHECK_COLOR_FAIL_RESULT` | `31;1` | _Used to display final summary (if tests fail)_ |
| `CHECK_COLOR_PASS` | `32` | _Used to display 'PASS'_ |
| `CHECK_COLOR_PASS_RESULT` | `32;1` | _Used to display final summary (if tests pass)_ |
| `CHECK_COLOR_STDOUT_HEADER` | `34;1` | _Used to display 'Standard Output'_ |
| `CHECK_COLOR_STDOUT` | `39;2` | _Used to display the standard output text_ |
| `CHECK_COLOR_STDERR_HEADER` | `31;1` | _Used to display 'Standard Error'_ |
| `CHECK_COLOR_STDERR` | `39;2` | _Used to display the standard error text_ |
| `CHECK_COLOR_STACKTRACE_HEADER` | `33;1` | _Used to display 'Stacktrace'_ |
| `CHECK_COLOR_STACKTRACE_LINE` | `34` | _Used to display stacktrace file name, line number, and function name_ |
| `CHECK_COLOR_STACKTRACE_CODE` | `33` | _Used to display the stacktrace line of source code_ |

> I recommend you put these into your `.checkrc` (_don't forget to `export` them_)

#### Want to change the colors _as the tests run?_

Feel free to combine hooks with colors!

##### Example `.checkrc`

```sh
COLORS=(33 34 35 36 35 34)
COLOR_INDEX=0

beforeTest() {
  export CHECK_COLOR_TESTNAME="${COLORS[$COLOR_INDEX]}"
  (( COLOR_INDEX++ ))
  (( COLOR_INDEX == ${#COLORS[@]} )) && COLOR_INDEX=0
}
```

##### Screenshot

<img src="/assets/images/screenshot_rainbow.png" style="max-height: 300px; border-radius: 2%; border: 1px solid; border-color: #666 !important;  padding: 10px; display: inline-block;" />