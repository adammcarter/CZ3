# CZ3

The [Z3 theorem prover](https://github.com/Z3Prover/z3)'s official release, repackaged so a
Swift package can depend on it.

- macOS arm64 only (macOS 13 or later).
- Z3's C API, imported into Swift as the module `CZ3`.
- Statically linked: no Homebrew, no system library, no dylib to ship.

Each release holds `CZ3.xcframework.zip`, built by GitHub Actions from Z3's own release zip:
its `libz3.a`, its C headers (without `z3++.h`), a module map and Z3's licence. Nothing in
Z3 is changed.

## Use

```swift
dependencies: [
  .package(url: "https://github.com/adammcarter/CZ3.git", exact: "5.3.3"),
],
targets: [
  .target(name: "MyTarget", dependencies: [.product(name: "CZ3", package: "CZ3")]),
]
```

```swift
import CZ3

let config = Z3_mk_config()
let context = Z3_mk_context(config)
```

## Versions

Each tag is the Z3 version it carries.

| Tag | Z3 | Built from | SHA-256 of that zip |
|---|---|---|---|
| `5.3.3` | 5.3.3 | `https://github.com/Z3Prover/z3/releases/download/z3-5.3.3/z3-5.3.3-arm64-osx-13.3.zip` | `6957e6c75266d7ca8fa77030e86e83d78624567dcdf34cc11f4192fdc6f93c6b` |

Z3 publishes no checksum for that file; the SHA-256 above is from the packager's own
download. The build refuses any download that doesn't match the SHA-256 it is given.

## Release a new version

Run the **Release** workflow (Actions tab, or
`gh workflow run release.yml -f version=<version> -f sha256=<sha256>`, adding
`-f zip_name=<file>` if the macOS arm64 zip has another name). It runs
`Scripts/build.sh`, writes the new url and checksum into `Package.swift`, commits that,
tags it with the bare version and creates the release with the zip attached.

To build by hand: `Scripts/build.sh <version> <sha256> [zip-name]` writes
`build/CZ3.xcframework.zip` and prints its SwiftPM checksum.

## Licence

The wrapper files are MIT (see `LICENSE`). Z3 itself is MIT, copyright Microsoft
Corporation; its licence ships inside the XCFramework as `LICENSE.txt`.
