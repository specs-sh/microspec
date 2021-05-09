---
title: ""
# layout: collection
# collection: docs
# entries_layout: grid
# classes: wide
permalink: /
author_profile: true
show_links: true
show_download_button: true
always_show_sidebar: true
sidebar:
  nav: sidebar
---

[![Mac (BASH 3.2)](https://github.com/specs-sh/check/workflows/Mac%20(BASH%203.2)/badge.svg)](https://github.com/specs-sh/check/actions?query=workflow%3A%22Mac+%28BASH+3.2%29%22) [![BASH 4.0](https://github.com/specs-sh/check/workflows/BASH%204.0/badge.svg)](https://github.com/specs-sh/check/actions?query=workflow%3A%22BASH+4.0%22) [![BASH 4.4](https://github.com/specs-sh/check/workflows/BASH%204.4/badge.svg)](https://github.com/specs-sh/check/actions?query=workflow%3A%22BASH+4.4%22) [![BASH 5.0](https://github.com/specs-sh/check/workflows/BASH%205.0/badge.svg)](https://github.com/specs-sh/check/actions?query=workflow%3A%22BASH+5.0%22)

# `$ check`

> _Tiny Shell Script Testing Framework ( < 50 LOC )_

- Supports Mac OS X default BASH version (`3.2.57`)
- Supports modern BASH versions (`4.0`, `4.4`, `5.0`)
- Customizable ( _create custom formatters or even change the test syntax!_ )

### Install

```sh
curl -o- https://check.shellbox.sh/install.sh | bash
```

### Example Test

```sh
setup() {
  # Some setup code that runs before each test
  # Supports multiple setup blocks:
  # » any function starting with 'setup' or 'before' (case-insensitive)
}

teardown() {
  # Some code that runs after each test, even if it fails.
  # Supports multiple teardown blocks:
  # » any function starting with 'teardown' or 'after' (case-insensitive)
}

# Any function which starts with 'test' '@test' 'spec' or '@spec'
# is considered a test. Tests are each run in separate processes.
test.shouldPass() {
  echo "STDOUT from shouldPass"
  echo "STDERR from shouldPass" >&2
  (( 1 == 1 ))
}

test.shouldFail() {
  echo "STDOUT from shouldFail"
  echo "STDERR from shouldFail" >&2
  (( 1 == 0 )) # <-- This line fails so the whole test fails
  (( 1 == 1 )) # <-- even though the final result passes.
}
```

### Usage

```sh
$ check [options] [files or folders containing test files]
```

> If no files or directories are provided, `check` will recursively search  
> for any files in the current directory named `*.test.sh` or `*.spec.sh`.

### Example Output

<img alt="Screenshot of check test output" src="/assets/images/screenshot.png" style="max-height: 300px; border-radius: 2%; border: 1px solid; border-color: #666 !important;  padding: 10px; display: inline-block;" />

> Test STDOUT and STDERR is printed only if a test fails (_or if `VERBOSE=true`_)  
> The failing line of code is also displayed (_including file path and line number_)

---

### Why?

> I wanted a tiny testing utility which I could easily include in each repository  
> (_rather than a tool like BATS which is not distributed as a single executable_)

#### Why under 50 LOC?

> Just sounded like an interesting challenge.  
> The executable is also under 10K which was my initial goal.  
> The 49 LOC are pretty tightly squished, but - _meh_ - it was fun!