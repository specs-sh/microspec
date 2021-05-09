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
}

teardown() {
  # Some code that runs after each test, even if it fails
}

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

### Usage

```sh
$ check [files or folders containing test files]
```

### Example Output

<img alt="Screenshot of check test output" src="/assets/images/screenshot.png" style="max-height: 300px; border-radius: 2%; border: 1px solid; border-color: #666 !important;  padding: 10px; display: inline-block;" />

---