assert() {
  local ASSERT_VERSION=0.2.2
  [ $# -eq 1 ] && [ "$1" = "--version" ] && { echo "assert version $ASSERT_VERSION"; return 0; }
  local ___assert___command="$1"
  shift
  "$___assert___command" "$@"
  if [ $? -ne 0 ]
  then
    echo "Expected to succeed, but failed: \$ $___assert___command $@" >&2
    exit 1
  fi
  return 0
}