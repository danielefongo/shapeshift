#!/usr/bin/env zsh

git submodule init
git submodule update

setopt shwordsplit

decorate() {
  print
  echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  echo "$@"
  echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  print
}

export TERM=xterm

testFiles="$(find tests -type f -name "*.test.zsh")"
for test in $testFiles; do
  decorate "Run $test..."
  eval zsh $test 2>&1
  local exitcode=$?
  [ "$exitcode" -ne 0 ] && exitCode=$exitcode
done

if [ "$exitCode" -eq 0 ]; then
  decorate "All tests passed."
else
  decorate "Some tests failed."
  exit $exitCode
fi