// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Swires",
    targets: [
        .systemLibrary(name: "raylib", path: "./raylib/include"),
        .executableTarget(
            name: "Swires",
            dependencies: [
                .target(name: "raylib")
            ],
            path: "Sources",
            linkerSettings: [
                .unsafeFlags(["./raylib/lib/libraylib.a", "-lm"])
            ]
        ),
    ]
)
