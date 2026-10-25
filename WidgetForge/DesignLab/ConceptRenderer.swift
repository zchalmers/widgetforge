import SwiftUI

/// Headless renderer for the design lab. On demand it rasterizes every
/// registered `WidgetConcept` at every `ConceptFamily` into PNGs under the
/// app's Documents directory, plus an `index.json` manifest. The controller
/// pulls these off the simulator/device to review 20+ designs at once — no
/// interactive HID needed.
///
/// Invoked when the process launches with env `WF_RENDER_CONCEPTS=1`.
@MainActor
enum ConceptRenderer {
    static var isRequested: Bool {
        ProcessInfo.processInfo.environment["WF_RENDER_CONCEPTS"] == "1"
    }

    /// Output directory: <Documents>/concept-shots.
    static var outputDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("concept-shots", isDirectory: true)
    }

    struct Manifest: Codable {
        struct Entry: Codable { let id: String; let title: String; let blurb: String
            let scheme: String; let files: [String] }
        let entries: [Entry]
    }

    static func renderAll() {
        let ctx = ConceptContext.sample
        let fm = FileManager.default
        try? fm.createDirectory(at: outputDir, withIntermediateDirectories: true)

        var manifestEntries: [Manifest.Entry] = []
        for concept in ConceptRegistry.all {
            var files: [String] = []
            for family in ConceptFamily.allCases {
                let view = concept.make(ctx, family)
                    .frame(width: family.size.width, height: family.size.height)
                    .environment(\.colorScheme, concept.scheme)
                let renderer = ImageRenderer(content: view)
                renderer.scale = 3
                renderer.proposedSize = ProposedViewSize(family.size)
                guard let img = renderer.uiImage, let data = img.pngData() else { continue }
                let name = "\(concept.id)__\(family.rawValue).png"
                try? data.write(to: outputDir.appendingPathComponent(name))
                files.append(name)
            }
            manifestEntries.append(.init(id: concept.id, title: concept.title, blurb: concept.blurb,
                                         scheme: concept.scheme == .dark ? "dark" : "light", files: files))
        }
        if let data = try? JSONEncoder().encode(Manifest(entries: manifestEntries)) {
            try? data.write(to: outputDir.appendingPathComponent("index.json"))
        }
        // Marker file so the controller can poll for completion.
        try? Data("done \(manifestEntries.count)".utf8)
            .write(to: outputDir.appendingPathComponent("_COMPLETE"))
    }
}
