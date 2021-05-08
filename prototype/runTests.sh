echo "SOURCE RUN TESTS"

runTests() {
  echo "RUN TESTS $*"
  local __microSpec__testFn __microSpec__testFnOutput __microSpec__testFnExitCode __microSpec__testFnHead __microSpec__testFnBody __microSpec__newTestFn __microSpec__newline=$'\n'
  if (( $# == 0 )); then
    local -a __microSpec__testFns=($( declare -pF | awk '{ print $3 }' | grep "^test\|^spec" ))
    for __microSpec__testFn in "${__microSpec__testFns[@]}"; do
      # __microSpec__testFnOutput="$( MICROSPEC_TEST_FUNCTION="$__microSpec__testFn" "$0" 2>&1 )"
      __microSpec__testFnOutput="$( runTests "$__microSpec__testFn" 2>&1 )"
      __microSpec__testFnExitCode=$?
      echo "OUTPUT: $__microSpec__testFnExitCode"
      if (( $__microSpec__testFnExitCode == 0 )); then
        echo -e "[\e[32mPASS\e[0m] $__microSpec__testFn"
      else
        echo -e "[\e[31mFAIL\e[0m] $__microSpec__testFn"
        printf '  \e[39;1m%s\e[0m\n%s\n' Output: "$( echo "$__microSpec__testFnOutput" | sed "s/^/    /" )"
      fi
    done
  else
    local __microSpec__testFn="$1"
    echo "FN TO RUN $__microSpec__testFn"
    declare -f "$__microSpec__testFn"
    trap __microSpec__stacktrace ERR
    if (( ${BASH_VERSINFO[0]} < 4 )) || [ "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}" = 4.0 ]; then
      echo DEBUG MODE
      __microSpec__testFnHead="$( declare -f "$__microSpec__testFn" | head -2 )"
      __microSpec__testFnBody="$( declare -f "$__microSpec__testFn" | tail -n +3 )"
      __microSpec__newTestFn="$__microSpec__testFnHead${__microSpec__newline}trap '(( \$? == 0 )) || { __microSpec__stacktrace \"\$0\" \"\$LINENO\"; exit 1; }' DEBUG${__microSpec__newline}$__microSpec__testFnBody"
      eval "$__microSpec__newTestFn"
    fi
    set -e
    echo "RUNNING IT"
    $__microSpec__testFn
    echo "RAN IT"
  fi
}

__microSpec__stacktrace() {
  if (( $# > 0 )); then
    local -i __microSpec__lineNo="$(( $2 + 2 ))"
    echo -e "\e[31;1mStacktrace:\e[0m"
    echo -e "\e[34m$1:$__microSpec__lineNo\e[0m \e[36m$__microSpec__testFn()\e[0m\n\e[93m$( sed "${__microSpec__lineNo}q;d" "$1" | sed "s/^ *//g" | sed "s/^/    /" )\e[0m"
  else
    local __microSpec__printedStacktraceHeader
    for (( i = 0 ; i < ${#BASH_SOURCE[@]}; i++ )); do
      [ -z "${BASH_LINENO[i]}" ] || (( ${BASH_LINENO[i]} == 0 )) && break
      [[ "${BASH_SOURCE[i+1]}" = *runTests* ]] && continue
      [ -z "$__microSpec__printedStacktraceHeader" ] && { __microSpec__printedStacktraceHeader=true; echo -e "\e[31;1mStacktrace:\e[0m"; }
      echo -e "\e[34m${BASH_SOURCE[i+1]}:${BASH_LINENO[i]}\e[0m \e[36m${FUNCNAME[i+1]}()\e[0m\n\e[93m$( sed "${BASH_LINENO[i]}q;d" "${BASH_SOURCE[i+1]}" | sed "s/^ *//g" | sed "s/^/    /" )\e[0m"
    done
  fi
}

echo "CALLING RUN TESTS"
runTests