#!/usr/bin/env bash
# Every check the repo has, in order: parse, Godot unit tests, Python tests, room tools, the
# one rule, and an actual 90-frame boot. Exits non-zero if any fails; ends with one summary line.
#
# Godot --script tests print an object.cpp cleanup warning as their LAST line, so the result is
# read from the "N passed, M failed" line, never from tail -1.
set -u
cd "$(dirname "$0")/.."

# `godot` is often a shell alias, which a script can't see. Override with GODOT=/path/to/godot.
GODOT=${GODOT:-$(command -v godot || echo /Applications/Godot.app/Contents/MacOS/Godot)}
if [[ ! -x $GODOT ]]; then echo "check_all: no godot binary (set GODOT=…)"; exit 2; fi

failed=()
passed=0
log=$(mktemp)
trap 'rm -f "$log"' EXIT

# Godot reports script/parse errors in its output but can still exit 0.
godot_errors() { grep -qE 'SCRIPT ERROR|Parse Error|^ERROR:' "$log"; }

run() {  # run <name> <cmd...>: pass on exit 0
	local name=$1; shift
	if "$@" >"$log" 2>&1; then
		passed=$((passed + 1)); echo "ok    $name"
	else
		failed+=("$name"); echo "FAIL  $name"; sed 's/^/      /' "$log" | tail -20
	fi
}

run_godot() {  # like run, but also fails on engine-reported errors
	local name=$1; shift
	if "$@" >"$log" 2>&1 && ! godot_errors; then
		passed=$((passed + 1)); echo "ok    $name"
	else
		failed+=("$name"); echo "FAIL  $name"; tail -20 "$log" | sed 's/^/      /'
	fi
}

run_godot "import (parse check)" "$GODOT" --headless --import

for t in tests/test_*.gd; do
	name="godot $(basename "$t")"
	"$GODOT" --headless --script "$t" >"$log" 2>&1
	code=$?
	result=$(grep -E '^[0-9]+ passed, [0-9]+ failed' "$log" | tail -1)
	if [[ $code -eq 0 && -n $result && $result == *" 0 failed" ]] && ! godot_errors; then
		passed=$((passed + 1)); echo "ok    $name ($result)"
	else
		failed+=("$name"); echo "FAIL  $name (${result:-no result line}, exit $code)"
		grep -vE '^\s*ok ' "$log" | head -20 | sed 's/^/      /'
	fi
done

for t in scripts/test_*.py; do
	run "python $(basename "$t")" python3 "$t"
done

run "validate_rooms" python3 scripts/validate_rooms.py
run "seal_test" python3 scripts/seal_test.py
run "lint_rooms" python3 scripts/lint_rooms.py

# The one rule (CLAUDE.md): no pitch literal in any .gd outside the two exempt paths.
# The (\./)? keeps the filter working whether grep prints "./tests/…" or "tests/…".
hits=$(grep -rnE '"[A-G](#|b)?[0-9]"' --include='*.gd' . | grep -vE '^(\./)?(tests|scripts/music/note_names)')
if [[ -z $hits ]]; then
	passed=$((passed + 1)); echo "ok    one-rule grep"
else
	failed+=("one-rule grep"); echo "FAIL  one-rule grep"; echo "$hits" | sed 's/^/      /'
fi

run_godot "boot (--quit-after 90)" "$GODOT" --headless --quit-after 90

total=$((passed + ${#failed[@]}))
if [[ ${#failed[@]} -eq 0 ]]; then
	echo "check_all: $passed/$total passed"
else
	echo "check_all: ${#failed[@]}/$total FAILED — ${failed[*]}"
	exit 1
fi
