// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "frollo-ios-sdk-example",
    dependencies: [
        .package(url: "git@bitbucket.org:frollo1/frollo-ios-sdk.git", from: "1.0.0")
    ]
)
