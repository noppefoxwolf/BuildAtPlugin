// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildAtPlugin",
    products: [
        .plugin(
            name: "BuildAtPlugin",
            targets: ["BuildAtPlugin"]),
    ],
    targets: [
        .plugin(
            name: "BuildAtPlugin",
            capability: .buildTool()
        ),
    ]
)
