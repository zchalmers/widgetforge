import SwiftUI
import WidgetForgeKit
import UIKit

struct HomeView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.tab) {
            GalleryView()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(AppRouter.Tab.gallery)

            MyWidgetsView()
                .tabItem { Label("My Widgets", systemImage: "rectangle.stack.fill") }
                .tag(AppRouter.Tab.myWidgets)

            AppsView()
                .tabItem { Label("Apps", systemImage: "app.badge.checkmark") }
                .tag(AppRouter.Tab.apps)

            RecoveryView()
                .tabItem { Label("Alerts", systemImage: "exclamationmark.triangle.fill") }
                .tag(AppRouter.Tab.recovery)

            DebugDataView()
                .tabItem { Label("Debug", systemImage: "ladybug.fill") }
                .tag(AppRouter.Tab.debug)
        }
        .tint(DesignSystem.suiteAccent)
    }
}
