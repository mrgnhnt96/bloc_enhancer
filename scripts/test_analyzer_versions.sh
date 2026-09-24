#!/usr/bin/env bash
# Test bloc_enhancer_gen with each major analyzer version (8 through 14).
# Ensures code generation and compilation work across analyzer releases.
#
# analyzer is pinned as a regular dependency of bloc_enhancer_test (not a
# dependency override) so pub still enforces every other package's analyzer
# constraint and resolves a compatible build_runner / dart_style / source_gen.

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$ROOT/bloc_enhancer_test"
BACKUP_FILES=(
  "$TEST_DIR/pubspec.yaml"
  "$TEST_DIR/pubspec.lock"
)

# One version per major branch supported by bloc_enhancer_gen (>=8.0.0 <15.0.0).
VERSIONS=(8.4.1 9.0.0 10.0.0 11.0.0 12.1.0 13.3.0 14.4.0)

restore_files() {
  for file in "${BACKUP_FILES[@]}"; do
    if [[ -f "$file.bak" ]]; then
      mv "$file.bak" "$file"
    fi
  done
}

trap restore_files EXIT

run_test() {
  local version=$1
  echo ""
  echo "========================================"
  echo "Testing analyzer $version"
  echo "========================================"

  # Start from the committed pubspec so each run pins exactly one version
  cp "$TEST_DIR/pubspec.yaml.bak" "$TEST_DIR/pubspec.yaml"
  rm -f "$TEST_DIR/pubspec.lock"
  cd "$TEST_DIR" && dart pub add "analyzer:$version"

  # Build generator and run codegen on test package
  cd "$TEST_DIR" && dart run build_runner build --delete-conflicting-outputs

  # Run tests
  cd "$TEST_DIR" && dart test

  echo "✓ analyzer $version: build and tests passed"
}

for file in "${BACKUP_FILES[@]}"; do
  cp "$file" "$file.bak"
done

echo "Testing bloc_enhancer_gen with analyzer versions: ${VERSIONS[*]}"
for v in "${VERSIONS[@]}"; do
  run_test "$v"
done

restore_files
trap - EXIT

cd "$TEST_DIR" && dart pub get

echo ""
echo "All analyzer versions passed!"
