import SwiftUI
import WidgetForgeKit
import WidgetKit
import ThemeKitSwiftUICore
import ThemeKitThemeManager

/// Full-screen canvas layout editor. Editing happens directly on the live
/// preview: drag to move, corner-drag to resize, tap to configure, X to delete,
/// tap an empty "+" slot to add. A compact top bar holds the name, the fixed
/// family, and the background. Validation runs on every mutation; Save persists
/// via `LayoutStore.write`.
struct LayoutEditorSheet: View {
    let original: WidgetLayout
    var onSave: (WidgetLayout) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: WidgetLayout
    @State private var validationError: WidgetForgeError?
    @State private var confirmingCancel = false
    @State private var saveError: String?
    @State private var editingCellId: Cell.ID?
    @State private var showThemePicker = false
    // Add flow: tapped slot -> pick type -> configure a pending new cell.
    @State private var addingAtSlot: GridPoint?
    // Cell staged by the type picker; presented for config only after the type
    // sheet fully dismisses (see the slot sheet's onDismiss) so we never present
    // one sheet while another is dismissing.
    @State private var stagedNewCell: Cell?
    @State private var pendingNewCell: Cell?

    init(original: WidgetLayout, onSave: @escaping (WidgetLayout) -> Void) {
        self.original = original
        self.onSave = onSave
        _draft = State(initialValue: original)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                topBar
                ValidationBanner(error: validationError).padding(.horizontal)
                if let saveError {
                    Text(saveError)
                        .font(.themeKit(forTextStyle: .caption1))
                        .foregroundStyle(DesignSystem.statusCritical)
                        .padding(.horizontal)
                }
                Spacer(minLength: 0)
                EditorCanvas(
                    layout: draft,
                    onReflow: { rearranged in draft.cells = rearranged; revalidate() },
                    onResizeCell: { id, span in mutate { c in c.span = span } (id) },
                    onDeleteCell: { id in draft.cells.removeAll { $0.id == id }; revalidate() },
                    onTapCell: { id in editingCellId = id },
                    onTapEmptySlot: { slot in addingAtSlot = slot }
                )
                Spacer(minLength: 0)
            }
            .padding(.top, 8)
            .navigationTitle("Edit layout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if draft == original { dismiss() } else { confirmingCancel = true }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(validationError != nil || draft == original)
                }
            }
            .sheet(item: cellSheetBinding) { boxed in
                if let idx = draft.cells.firstIndex(where: { $0.id == boxed.id }) {
                    CellEditorView(cell: draft.cells[idx]) { component in
                        draft.cells[idx].component = component
                        revalidate()
                    }
                }
            }
            .sheet(item: slotSheetBinding, onDismiss: {
                // Present the config sheet only now that the type picker has
                // fully dismissed, avoiding a present-while-dismissing race.
                if let staged = stagedNewCell {
                    stagedNewCell = nil
                    pendingNewCell = staged
                }
            }) { boxed in
                TypeGridPicker { kind in
                    // Stage a 1x1 cell at the tapped slot (or nearest legal).
                    // The config editor opens from this sheet's onDismiss.
                    let origin = legalOrigin(for: kind, near: boxed.point)
                    stagedNewCell = Cell(origin: origin, span: GridSize(cols: 1, rows: 1),
                                         component: ComponentDraft(kind: kind).makeComponent())
                }
            }
            .sheet(item: $pendingNewCell) { cell in
                CellEditorView(cell: cell) { component in
                    var placed = cell
                    placed.component = component
                    draft.cells.append(placed)
                    revalidate()
                }
            }
            .sheet(isPresented: $showThemePicker) {
                ThemePicker(layout: draft, selectedId: draft.themeId) { id in
                    draft.themeId = id
                    revalidate()
                }
            }
            .confirmationDialog("Discard your changes?", isPresented: $confirmingCancel,
                                titleVisibility: .visible) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep editing", role: .cancel) {}
            }
            .onAppear { revalidate() }
            .onChange(of: draft) { _, _ in revalidate() }
        }
    }

    // MARK: Top bar

    @ViewBuilder
    private var topBar: some View {
        HStack(spacing: 12) {
            TextField("Untitled Layout", text: $draft.name)
                .font(.themeKit(forTextStyle: .headline))
                .textFieldStyle(.plain)
            Text(draft.family.rawValue.capitalized)
                .font(.themeKit(forTextStyle: .caption1, weight: .semibold))
                .foregroundStyle(Color.preferredColor(.secondaryLabel))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(DesignSystem.cardFill))
            Menu {
                Button("System") { draft.background = .system }
                Button("Clear") { draft.background = .clear }
                ForEach(AccentChoice.Token.allCases, id: \.self) { t in
                    Button(t.rawValue.capitalized) { draft.background = .accentHex(hex(for: t)) }
                }
            } label: {
                Circle().fill(backgroundSwatch).frame(width: 26, height: 26)
                    .overlay(Circle().stroke(DesignSystem.cardStroke, lineWidth: 1))
            }
            Button {
                showThemePicker = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "paintpalette.fill")
                    Text(ThemeCatalog.theme(id: draft.themeId).name)
                        .font(.themeKit(forTextStyle: .caption1, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(DesignSystem.suiteAccent)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(DesignSystem.cardFill))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    private var backgroundSwatch: Color {
        switch draft.background {
        case .system: return DesignSystem.Widget.backgroundTop
        case .clear: return Color.gray.opacity(0.3)
        case .accentHex(let hex): return DesignSystem.color(fromHex: hex)
        }
    }

    private func hex(for token: AccentChoice.Token) -> String {
        switch token {
        case .amber: return "#F5A623"
        case .teal: return "#3ECCB8"
        case .violet: return "#8E7CFF"
        case .mint: return "#4ED9A4"
        case .coral: return "#FF7A66"
        }
    }

    // MARK: Mutation helpers

    /// Apply an in-place edit to the cell with `id`, then revalidate.
    private func mutate(_ edit: @escaping (inout Cell) -> Void) -> (Cell.ID) -> Void {
        { id in
            if let idx = draft.cells.firstIndex(where: { $0.id == id }) {
                edit(&draft.cells[idx]); revalidate()
            }
        }
    }

    /// First legal origin for a 1x1 cell of `kind` near the tapped slot; falls
    /// back to the tapped slot itself (validation catches the rare no-fit case).
    private func legalOrigin(for kind: Component.Kind, near slot: GridPoint) -> GridPoint {
        let span = GridSize(cols: 1, rows: 1)
        if CanvasEditIntent.canPlace(span: span, at: slot, family: draft.family,
                                     siblings: draft.cells, excluding: UUID()) {
            return slot
        }
        for row in 0..<draft.family.rows {
            for col in 0..<draft.family.cols {
                let p = GridPoint(col: col, row: row)
                if CanvasEditIntent.canPlace(span: span, at: p, family: draft.family,
                                             siblings: draft.cells, excluding: UUID()) {
                    return p
                }
            }
        }
        return slot
    }

    // MARK: Validate / save

    private func revalidate() {
        do { try LayoutValidator.validate(draft); validationError = nil }
        catch let e as WidgetForgeError { validationError = e }
        catch { validationError = nil }
    }

    private func save() {
        revalidate()
        guard validationError == nil else { return }
        var toSave = draft
        toSave.updatedAt = Date()
        do {
            try LayoutStore().write(toSave)
            WidgetCenter.shared.reloadAllTimelines()
            onSave(toSave)
            dismiss()
        } catch let e as WidgetForgeError {
            validationError = e
            saveError = "Save failed. Please review the layout."
        } catch {
            saveError = "Save failed: \(error.localizedDescription)"
        }
    }

    // MARK: Sheet item bridges

    private var cellSheetBinding: Binding<UUIDBox?> {
        Binding(get: { editingCellId.map(UUIDBox.init) }, set: { editingCellId = $0?.id })
    }
    private var slotSheetBinding: Binding<SlotBox?> {
        Binding(get: { addingAtSlot.map(SlotBox.init) }, set: { addingAtSlot = $0?.point })
    }
    private struct UUIDBox: Identifiable, Hashable { let id: UUID }
    private struct SlotBox: Identifiable, Hashable {
        let point: GridPoint
        var id: String { "\(point.col)-\(point.row)" }
    }
}
