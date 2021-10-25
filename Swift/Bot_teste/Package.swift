
import PackageDescription

let package = Package(
    name: "Bot",
    dependencies: [
        .package(url: "https://github.com/Azoy/Sword", from: "0.9.0")
    ],
    targets: [
       
        .target(
        name: "Bot",
        dependencies: ["Sword"]
            )
    ]
)
