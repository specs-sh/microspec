runTests() {
  local __microSpec__testFunction __microSpec__testFunctionOutput __microSpec__testFunctionExitCode __microSpec__testFunctionHead __microSpec__testFunctionBody __microSpec__newTestFunction __microSpec__newline=$'\n'
  if [ -z "$MICROSPEC_TEST_FUNCTION" ]; then
    local -a __microSpec__testFunctions=($( declare -pF | awk '{ print $3 }' | grep "^test\|^spec" ))
    for __microSpec__testFunction in "${__microSpec__testFunctions[@]}"; do
      __microSpec__testFunctionOutput="$( MICROSPEC_TEST_FUNCTION="$__microSpec__testFunction" "$0" 2>&1 )"
      __microSpec__testFunctionExitCode=$?
      if (( $__microSpec__testFunctionExitCode == 0 )); then
        echo "PASS: $__microSpec__testFunction"
      else
        echo "FAIL: $__microSpec__testFunction"
      fi
      # echo "[OUTPUT] => [$__microSpec__testFunctionOutput]"
    done
  else
    if (( ${BASH_VERSINFO[0]} < 4 )) || [ "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}" = 4.0 ]; then
      __microSpec__testFunctionHead="$( declare -f "$MICROSPEC_TEST_FUNCTION" | head -2 )"
      __microSpec__testFunctionBody="$( declare -f "$MICROSPEC_TEST_FUNCTION" | tail -n +3 )"
      __microSpec__newTestFunction="$__microSpec__testFunctionHead${__microSpec__newline}trap '(( \$? == 0 )) || exit \$?' DEBUG${__microSpec__newline}$__microSpec__testFunctionBody"
      eval "$__microSpec__newTestFunction"
    fi
    set -eE
    "$MICROSPEC_TEST_FUNCTION"
  fi
}

runTests