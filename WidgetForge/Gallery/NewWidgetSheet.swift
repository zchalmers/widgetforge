import SwiftUI
import WidgetForgeKit
import WidgetKit
import ThemeKitThemeManager

struct NewWidgetSheet: View {
    var onCreate: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var family: LayoutFamily = .medium
    @State private var prompt: String = ""
    @State private var isGenerating = false
    @State private var statusMessage: String?
    @State private var blankToEdit: WidgetLayout?

    private let store = LayoutStore()

    var body: some View {
        NavigationStack {
            Form {
                Section("Size") {
                    Picker("Size", selection: $family) {
                        Text("Small").tag(LayoutFamily.small)
                        Text("Medium").tag(LayoutFamily.medium)
                        Text("Large").tag(LayoutFamily.large)
                        Text("XL").tag(LayoutFamily.extraLarge)
                        Text("XL Portrait").tag(LayoutFamily.xlPortrait)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Describe it with AI") {
                    TextField("What should the widget show?", text: $prompt, axis: .vertical)
                        .lineLimit(2...4)
                    Button {
                        Task { await generate() }
                    } label: {
                        Label(isGenerating ? "Building…" : "Build with AI", systemImage: "wand.and.stars")
                    }
                    .disabled(prompt.trimmingCharacters(in: .whitespaces).isEmpty || isGenerating)
                }

                Section {
                    Button {
                        startBlank()
                    } label: {
                        Label("Start blank", systemImage: "plus.rectangle")
                    }
                } footer: {
                    if let statusMessage {
                        Text(statusMessage).foregroundStyle(Color.preferredColor(.criticalLabel))
                    }
                }
            }
            .navigationTitle("New Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fullScreenCover(item: $blankToEdit) { layout in
                LayoutEditorSheet(original: layout) { _ in
                    onCreate()
                    dismiss()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func generate() async {
        isGenerating = true
        defer { isGenerating = false }

        switch LayoutAuthor.availability() {
        case .available:
            if #available(iOS 26.0, *),
               let layout = await LayoutAuthor.generate(prompt: prompt, family: family) {
                try? store.write(layout)
                WidgetCenter.shared.reloadAllTimelines()
                onCreate()
                dismiss()
                return
            }
            seedFallback(prefix: "")
        case .unsupported:
            seedFallback(prefix: "Apple Intelligence isn't supported here. ")
        case .unavailable:
            seedFallback(prefix: "Apple Intelligence isn't ready. ")
        }
    }

    private func seedFallback(prefix: String) {
        let layout = LayoutAuthor.seedDefault(family: family)
        try? store.write(layout)
        WidgetCenter.shared.reloadAllTimelines()
        onCreate()
        statusMessage = "\(prefix)Created the default \(family.rawValue) layout — customize it in the editor."
    }

    private func startBlank() {
        // Single header cell so write() passes validation and the editor opens
        // on something visible.
        let layout = WidgetLayout(
            name: "New \(family.rawValue) widget",
            family: family,
            cells: [
                Cell(origin: GridPoint(col: 0, row: 0),
                     span: GridSize(cols: family.cols, rows: 1),
                     component: .header(HeaderConfig(title: "New Widget", subtitle: nil, accent: .fromApp)))
            ],
            background: .system
        )
        guard (try? store.write(layout)) != nil else {
            statusMessage = "Couldn't create the layout."
            return
        }
        WidgetCenter.shared.reloadAllTimelines()
        blankToEdit = layout
    }
}
