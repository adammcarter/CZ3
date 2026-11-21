// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "CZ3",
  platforms: [
    .macOS(.v13),
  ],
  products: [
    .library(name: "CZ3", targets: ["CZ3"]),
  ],
  targets: [
    .binaryTarget(
      name: "CZ3",
      url: "https://github.com/adammcarter/CZ3/releases/download/0.0.0/CZ3.xcframework.zip",
      checksum: "0000000000000000000000000000000000000000000000000000000000000000"
    ),
  ]
)
