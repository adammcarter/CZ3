#!/bin/bash
# Builds CZ3.xcframework.zip from an official Z3 release for macOS arm64.
#
# Downloads the release zip, refuses it unless its SHA-256 is the one given, builds an
# XCFramework from the release's static library and C headers (without z3++.h, which
# Swift can't import) plus a module map, copies Z3's licence in, zips it and prints the
# checksum Swift's package manager needs.
#
# Usage: Scripts/build.sh <z3-version> <sha256> [zip-name]
#   z3-version  a Z3 release, e.g. 5.3.3 (its tag is z3-<version>)
#   sha256      the expected SHA-256 of the official zip
#   zip-name    the zip's file name on the release page (default z3-<version>-arm64-osx-13.3.zip)
#
# Output: build/CZ3.xcframework.zip and build/checksum.txt
set -euo pipefail

usage="usage: Scripts/build.sh <z3-version> <sha256> [zip-name]"
version=${1:?$usage}
expected=${2:?$usage}
asset=${3:-z3-${version}-arm64-osx-13.3.zip}
url="https://github.com/Z3Prover/z3/releases/download/z3-${version}/${asset}"

repo_root=$(cd "$(dirname "$0")/.." && pwd)
out="$repo_root/build"
xcf="$out/CZ3.xcframework"
zip="$out/CZ3.xcframework.zip"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "build: downloading $url"
curl --fail --location --silent --show-error --output "$work/z3.zip" "$url"

actual=$(shasum -a 256 "$work/z3.zip" | awk '{ print $1 }')
if [[ $actual != "$expected" ]]; then
  echo "error: SHA-256 mismatch for $asset" >&2
  echo "  expected $expected" >&2
  echo "  got      $actual" >&2
  exit 1
fi
echo "build: SHA-256 matches ($actual)"

mkdir "$work/release"
unzip -q "$work/z3.zip" -d "$work/release"
releases=("$work"/release/z3-*/)
release=${releases[0]%/}
[[ -f $release/bin/libz3.a ]] || { echo "error: no bin/libz3.a in $asset" >&2; exit 1; }
[[ -f $release/include/z3.h ]] || { echo "error: no include/z3.h in $asset" >&2; exit 1; }
[[ -f $release/LICENSE.txt ]] || { echo "error: no LICENSE.txt in $asset" >&2; exit 1; }

headers="$work/headers"
mkdir "$headers"
cp "$release"/include/*.h "$headers/"
rm -f "$headers/z3++.h"
cat > "$headers/module.modulemap" <<'MODULEMAP'
module CZ3 [system] {
  header "z3.h"
  link "c++"
  export *
}
MODULEMAP

rm -rf "$xcf" "$zip" "$out/checksum.txt"
mkdir -p "$out"
xcodebuild -create-xcframework \
  -library "$release/bin/libz3.a" \
  -headers "$headers" \
  -output "$xcf"
cp "$release/LICENSE.txt" "$xcf/LICENSE.txt"

(cd "$out" && zip -qry "CZ3.xcframework.zip" "CZ3.xcframework")

checksum=$(cd "$repo_root" && swift package compute-checksum "$zip")
echo "$checksum" > "$out/checksum.txt"
echo "build: built $zip from Z3 $version"
echo "checksum: $checksum"
