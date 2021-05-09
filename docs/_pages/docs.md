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

When tests are run, there are a few conditions which mark a test as "_failing_":

- A test fails if the function returns a non-zero exit code, e.g. `return 1`
- A test fails if the function exits with a non-zero exit code, e.g. `exit 1`
- A test fails if the function runs _any statement_ which returns a non-zero exit code,  
  e.g. `(( 1 == 0 ))` or `output="$( echo "hello" | grep this-wont-be-found )"`

If none of these conditions are met, then a test will be marked as "_passing_".

When a failure condition is triggered, the triggering line of code is noted
and will be displayed along with the file path and line of code as a "_Stacktrace_".

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

## <i class="fad fa-volcano"></i> About <code>set -e</code>

By default, test files are run with the following BASH options configured:

- `set -o errexit` (`set -e`)
- `set -o errtrace` (`set -E`)
- `set -o functrace` (`set -T`)

The `errexit` option (_or `set -e` for short_) is what allows us to immediately
fail a test whenever any statement is executed which returns a non-zero exit code.

## <i class="fad fa-arrows-v"></i> Setup and Teardown


# <i class="fad fa-terminal"></i> Options
## <code>&lt;file&gt; &lt;directory&gt;</code>
## <code>-v / --verbose</code>
## <code>-q / --quiet</code>
## <code>-f / --filter</code>
## <code>-c / --config</code>
## <code>-s / --set / --no-set</code>
## <code>--color / --no-color</code>
## <code>--random / --no-random</code>
## <code>--formatter</code>
## <code>--file-pattern</code>
## <code>--test-pattern</code>
## <code>--setup-pattern</code>
## <code>--teardown-pattern</code>


# <i class="fad fa-cog"></i> Customization
## <i class="fad fa-feather-alt"></i> Customize Test Syntax
## <i class="fad fa-fish"></i> Test Hooks
## <i class="fad fa-print"></i> Write Formatters
## <i class="fad fa-palette"></i> Customize Colors
