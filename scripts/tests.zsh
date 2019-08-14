#!/usr/bin/env zsh

if [ ! -d shunit2 ]; then
  git clone --single-branch --branch 'v2.1.7' https://github.com/kward/shunit2
fi

if [ ! -d mockz ]; then
  git clone https://github.com/danielefongo/mockz
fi

setopt shwordsplit

decorate() {
  print
  echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  echo "$@"
  echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  print
}

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