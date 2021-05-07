testTrap='[ -n "${FUNCNAME[*]}" ] && echo -e "\e[31;1mStacktrace:\e[0m"; for ((i=0;i<${#BASH_SOURCE[@]};i++)); do [ -z "${FUNCNAME[i]}" ] || [ -z "${LINENO[i]}" ] && continue; echo -e "\e[34m${BASH_SOURCE[i]}:${LINENO[i]}\e[0m \e[36m${FUNCNAME[i]}()\e[0m\n\e[93m$( sed "${LINENO[i]}q;d" "${BASH_SOURCE[i]}" | sed "s/^ *//g" | sed "s/^/    /" )\e[0m"; done'
for testFn in $( declare -pF | awk '{ print $3 }' | grep "^test\|^spec" | sort -R ); do
  output="$( trap "$testTrap" ERR; [ -z "${BEFORE_TEST+x}" ] && set -eE || eval "$BEFORE_TEST"; $testFn 2>&1 )"
  case $? in
    0) echo -e "[\e[32mPASS\e[0m] $testFn"; [ "${VERBOSE:-}" = true ] && [ -n "$output" ] && printf '  \e[39;1m%s\e[0m\n%s\n' Output: "$( echo -e "$output" | sed 's/^/    /' )" ;;
    *) echo -e "[\e[31mFAIL\e[0m] $testFn"; anyFailed=$(( anyFailed = anyFailed + 1 )); [ -n "$output" ] && printf '  \e[39;1m%s\e[0m\n%s\n' Output: "$( echo -e "$output" | sed 's/^/    /' )" ;;
  esac
done; [ -n "${anyFailed:-}" ] && { echo -e "\e[31;1m$anyFailed test(s) failed\e[0m" >&2; exit 1; } || echo -e "\e[32;1mTests passed\e[0m"