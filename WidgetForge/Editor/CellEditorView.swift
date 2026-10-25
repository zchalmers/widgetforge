import SwiftUI
import WidgetForgeKit

/// Config-only editor for an existing cell's component. Size, position, and
/// delete are handled directly on the canvas, so this view only edits the
/// component's data source and options via the shared `ComponentConfigForm`.
struct CellEditorView: View {
    let cell: Cell
    var onSave: (Component) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: ComponentDraft

    init(cell: Cell, onSave: @escaping (Component) -> Void) {
        self.cell = cell
        self.onSave = onSave
        _draft = State(initialValue: ComponentDraft.from(cell.component))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Component") {
                    Text(draft.kind.displayName).font(.headline)
                }
                ComponentConfigForm(draft: $draft)
            }
            .navigationTitle("Edit cell")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft.makeComponent())
                        dismiss()
                    }
                    .disabled(!draft.isReadyToCommit)
                }
            }
        }
    }
}
