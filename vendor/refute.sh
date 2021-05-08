refute() {
  local REFUTE_VERSION=0.2.2
  [ $# -eq 1 ] && [ "$1" = "--version" ] && { echo "refute version $REFUTE_VERSION"; return 0; }
  local ___assert___command="$1"
  shift
  "$___assert___command" "$@"
  if [ $? -eq 0 ]
  then
    echo "Expected to fail, but succeeded: \$ $___assert___command $@" >&2
    exit 1
  fi
  return 0
}