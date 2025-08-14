// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleThreadCalculator",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SimpleThreadCalculator",
            dependencies: ["SimpleThreadCalculatorCore"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(name: "SimpleThreadCalculatorCore", 
                dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(name: "SimpleThreadCalculatorTests",
                    dependencies: ["SimpleThreadCalculatorCore"]
        )
    ]
)
