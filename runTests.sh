for testFn in $( declare -pF | awk '{ print $3 }' | grep ^test | sort -R ); do
  output="$( [ -z "${BEFORE_TEST+x}" ] && set -eE || eval "$BEFORE_TEST"; $testFn 2>&1 )"
  case $? in
    0) echo -e "[\e[32mPASS\e[0m] $testFn"; [ "$VERBOSE" = true ] && printf '%s\n%s\n' Output: "$output" ;;
    *) echo -e "[\e[31mFAIL\e[0m] $testFn"; anyFailed=$(( anyFailed = anyFailed + 1 )); printf '%s\n%s\n' Output: "$output" ;;
  esac
done
[ -n "$anyFailed" ] && { echo "$anyFailed test(s) failed" >&2; exit 1; }