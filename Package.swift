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
      url: "https://github.com/adammcarter/CZ3/releases/download/5.3.3/CZ3.xcframework.zip",
      checksum: "0771581303a568cdb4fe9b88f19f1c5a17b5d2fb83b582efbf56a815d1d70edc"
    ),
  ]
)
