//
//  WidgetForgeAppDelegate.swift
//  WidgetForge
//
//  BGTaskScheduler.register MUST run synchronously during launch. SwiftUI's
//  WindowGroup .task { } fires too late. UIApplicationDelegateAdaptor gives
//  us the didFinishLaunchingWithOptions hook we need.
//

import UIKit
import SwiftUI
import ThemeKitThemeManager
import ThemeKitSwiftUICore

final class WidgetForgeAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Register the Widget "72" font family before any ThemeKit view renders.
        // Idempotent (guarded internally) and per-process, so the widget
        // extension must register separately in WidgetForgeWidgetsBundle.init().
        Font.registerThemeKitFonts()
        setupThemeKitAppearance()
        WidgetForgeRefreshTask.register()
        WidgetForgeRefreshTask.schedule(reason: "didFinishLaunching")
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        WidgetForgeRefreshTask.schedule(reason: "didEnterBackground")
    }

    /// Applies the Widget "72" typeface to UIKit-backed nav bars, matching the
    /// look in Widget's reference apps. UIFont.preferredThemeKitFont is internal to
    /// the open-source package, so we build the 72 face directly (it is already
    /// registered above) and scale it with UIFontMetrics for Dynamic Type.
    private func setupThemeKitAppearance() {
        let nav = UINavigationBar.appearance()
        nav.prefersLargeTitles = true
        if let large = themeKitUIFont(face: "72-Bold", size: 34, style: .largeTitle) {
            nav.largeTitleTextAttributes = [.font: large]
        }
        if let title = themeKitUIFont(face: "72-Bold", size: 17, style: .headline) {
            nav.titleTextAttributes = [.font: title]
        }
    }

    private func themeKitUIFont(face: String, size: CGFloat, style: UIFont.TextStyle) -> UIFont? {
        guard let base = UIFont(name: face, size: size) else { return nil }
        return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
    }
}
