// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "WidgetForgeKit",
    // iOS-only: the optional ThemeKit module is UIKit-based, so this package
    // cannot build for macOS.
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "WidgetForgeKit", targets: ["WidgetForgeKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.18.0"),
        // Replace this placeholder with a compatible visual-theme module before
        // resolving packages. DesignSystem and the themed views use its modules.
        .package(url: "https://example.com/widgetforge-theme-kit.git", from: "26.4.3")
    ],
    targets: [
        .target(
            name: "WidgetForgeKit",
            dependencies: [
                .product(name: "ThemeKitSwiftUICore", package: "widgetforge-theme-kit"),
                .product(name: "ThemeKitThemeManager", package: "widgetforge-theme-kit"),
                // ThemeKitSwiftUICore's binary module interface depends on
                // ThemeKitCharts, so it must be linked even though we don't import
                // it directly.
                .product(name: "ThemeKitCharts", package: "widgetforge-theme-kit")
            ],
            resources: [
                // Sample publisher icons, shown in the Apps tab and app tiles. Ships in
                // the module bundle so both the app and widget extension can load
                // them via Bundle.module.
                .process("Resources/AppIcons.xcassets")
            ]
        ),
        .testTarget(
            name: "WidgetForgeKitTests",
            dependencies: [
                "WidgetForgeKit",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            resources: [.process("__Snapshots__"), .copy("Fixtures")]
        )
    ]
)
