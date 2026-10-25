#if canImport(SwiftUI)
import SwiftUI
import WidgetForgeKit

/// Renders a real sample `WidgetLayout` through the actual `LayoutRenderer`
/// under every theme in `ThemeCatalog`, writing PNGs so themes can be reviewed
/// exactly as the shipped widget (and editor preview) will paint them. This is
/// the true end-to-end proof of the theme engine, unlike the standalone concept
/// mockups. Triggered by env `WF_RENDER_THEMES=1`.
@MainActor
enum ThemeRenderer {
    static var isRequested: Bool {
        ProcessInfo.processInfo.environment["WF_RENDER_THEMES"] == "1"
    }

    static var outputDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("theme-shots", isDirectory: true)
    }

    static func renderAll() {
        let fm = FileManager.default
        try? fm.createDirectory(at: outputDir, withIntermediateDirectories: true)

        // A rich sample layout (medium 4x2) exercising the common component set:
        // header, count, metric, status, progress, list.
        let manifests = SampleData.merged(withReal: ManifestStore().readAll())
        let context = RenderContext(pool: SlicePool(manifests), registry: .default)

        for theme in ThemeCatalog.all {
            for (famName, size) in [("medium", CGSize(width: 360, height: 170)),
                                    ("large", CGSize(width: 360, height: 376))] {
                let layout = sampleLayout(family: famName == "medium" ? .medium : .large)
                let view = LayoutRenderer(layout: layout, context: context)
                    .widgetTheme(theme)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .environment(\.colorScheme, theme.prefersDark ? .dark : .light)
                let renderer = ImageRenderer(content: view)
                renderer.scale = 3
                renderer.proposedSize = ProposedViewSize(size)
                if let img = renderer.uiImage, let data = img.pngData() {
                    try? data.write(to: outputDir.appendingPathComponent("\(theme.id)__\(famName).png"))
                }
            }
        }
        try? Data("done \(ThemeCatalog.all.count)".utf8)
            .write(to: outputDir.appendingPathComponent("_COMPLETE"))
    }

    /// Build a representative sample layout bound to real slice vocabulary.
    private static func sampleLayout(family: LayoutFamily) -> WidgetLayout {
        let b = { (slice: String) in DataBinding(bundleId: "com.example.Dashboard", sliceId: slice) }
        var cells: [Cell] = [
            Cell(origin: .init(col: 0, row: 0), span: .init(cols: family.cols, rows: 1),
                 component: .header(.init(title: "Pipeline", subtitle: "Today", accent: .fromApp))),
            Cell(origin: .init(col: 0, row: 1), span: .init(cols: 2, rows: 1),
                 component: .count(.init(binding: b("actionRequiredCount"), caption: "Need action", accent: .fromApp))),
            Cell(origin: .init(col: 2, row: 1), span: .init(cols: 2, rows: 1),
                 component: .status(.init(binding: b("pipelineHealth"), accent: .fromApp))),
        ]
        if family.rows >= 4 {
            cells.append(Cell(origin: .init(col: 0, row: 2), span: .init(cols: 4, rows: 1),
                 component: .progress(.init(binding: b("reaffirmProgress"), style: .bar, accent: .fromApp))))
            cells.append(Cell(origin: .init(col: 0, row: 3), span: .init(cols: 4, rows: 1),
                 component: .list(.init(binding: b("topActionDeals"), maxRows: 3, accent: .fromApp))))
        }
        return WidgetLayout(name: "Sample", family: family, cells: cells,
                            background: .system, createdAt: Date(), updatedAt: Date())
    }
}
#endif
