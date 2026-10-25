import SwiftUI
import WidgetForgeKit
import UIKit
import WidgetKit
import ThemeKitSwiftUICore
import ThemeKitThemeManager

/// Shows the AppRegistry entries grouped by displayName. Multiple bundle-id
/// variants for the same app (prod / internal / dev) collapse into one row —
/// the row's status reflects the best status across variants, so a single
/// installed variant flips the whole family to Ready.
struct AppsView: View {
    @State private var families: [AppFamily] = []
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            List {
                ForEach(families, id: \.displayName) { family in
                    AppRow(family: family)
                }
            }
            .navigationTitle("Apps")
            .task { refresh() }
            .refreshable { refresh() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { refresh() }
            }
        }
    }

    private func refresh() {
        let probe = UIKitURLSchemeProbe()
        let store = ManifestStore()
        let availability = AppAvailability(
            registry: .default,
            manifests: store,
            probe: probe
        )
        let results = availability.results()
        families = AppFamily.group(results: results)

        // Best-effort: delete manifests for apps that are no longer installed so
        // the widget stops serving stale slices from an uninstalled publisher.
        let removed = AppAvailability.pruneUninstalled(results: results, store: store)
        if removed > 0 {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

/// One row per user-facing app. Aggregates every bundle-id variant sharing the
/// same displayName. Row status = best status across all variants.
struct AppFamily {
    let displayName: String
    let variants: [AppAvailability.Result]

    /// Best-of. Ready > Stale > InstalledNotPublishing > NotInstalled.
    var status: AppAvailability.Status {
        // Ready wins over everything.
        if let r = variants.first(where: { if case .ready = $0.status { return true } else { return false } }) {
            return r.status
        }
        // Stale next — its associated Date differs per variant so pick the freshest one.
        let staleVariants = variants.compactMap { v -> Date? in
            if case .stale(let publishedAt) = v.status { return publishedAt } else { return nil }
        }
        if let freshest = staleVariants.max() {
            return .stale(publishedAt: freshest)
        }
        // Installed-but-not-publishing next.
        if variants.contains(where: { if case .installedNotPublishing = $0.status { return true } else { return false } }) {
            return .installedNotPublishing
        }
        return .notInstalled
    }

    /// Representative entry — first variant is fine for icon + accent since
    /// every variant of the same family shares those design tokens.
    var representative: AppRegistry.Entry {
        variants.first!.entry
    }

    static func group(results: [AppAvailability.Result]) -> [AppFamily] {
        // Preserve first-appearance order of displayName so the list stays
        // stable and mirrors the order in AppRegistry.default.
        var order: [String] = []
        var buckets: [String: [AppAvailability.Result]] = [:]
        for r in results {
            let key = r.entry.displayName
            if buckets[key] == nil { order.append(key) }
            buckets[key, default: []].append(r)
        }
        return order.compactMap { name in
            guard let variants = buckets[name], !variants.isEmpty else { return nil }
            return AppFamily(displayName: name, variants: variants)
        }
    }
}

private struct AppRow: View {
    let family: AppFamily

    var body: some View {
        ObjectItem(
            title: AttributedString(family.displayName),
            status: .text(AttributedString(label)),
            detailImage: iconImage
        )
        .detailImageStyle { config in
            Group {
                if let icon = realIcon {
                    // Real app icon: show at tile size, rounded, no tint.
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                } else {
                    // SF Symbol fallback, tinted with the app's accent.
                    config.detailImage
                        .font(.themeKit(forTextStyle: .title2))
                        .foregroundStyle(accent.tint)
                        .frame(width: 40)
                }
            }
        }
        .statusStyle { config in
            config.status
                .font(.themeKit(forTextStyle: .footnote, weight: .semibold))
                .foregroundStyle(statusColor)
        }
    }

    private var realIcon: Image? {
        DesignSystem.appIcon(named: family.representative.iconAssetName)
    }
    private var hasRealIcon: Bool { realIcon != nil }
    private var iconImage: Image { realIcon ?? Image(systemName: accent.symbol) }

    private var accent: DesignSystem.AppAccent {
        DesignSystem.accent(for: family.representative.bundleId)
    }

    /// ThemeKit semantic status colors — adaptive, so no hand-tuned legibility
    /// overrides are needed on the app's light or dark List background.
    private var statusColor: Color {
        switch family.status {
        case .ready: return Color.preferredColor(.positiveLabel)
        case .installedNotPublishing: return Color.preferredColor(.criticalLabel)
        case .stale: return Color.preferredColor(.criticalLabel)
        case .notInstalled: return Color.preferredColor(.tertiaryLabel)
        }
    }

    private var label: String {
        switch family.status {
        case .ready: return "Ready"
        case .installedNotPublishing: return "Open to activate"
        case .notInstalled: return "Not installed"
        case .stale: return "Stale"
        }
    }
}

/// Concrete `URLSchemeProbe` that uses `UIApplication.shared.canOpenURL`.
/// The probe method is marked `@MainActor` where called — `AppsView.refresh`
/// runs on the main actor by virtue of being inside a SwiftUI View task,
/// so `UIApplication.shared` access is safe there.
struct UIKitURLSchemeProbe: URLSchemeProbe {
    func canOpen(scheme: String) -> Bool {
        guard let url = URL(string: "\(scheme)://") else { return false }
        return MainActor.assumeIsolated {
            UIApplication.shared.canOpenURL(url)
        }
    }
}
