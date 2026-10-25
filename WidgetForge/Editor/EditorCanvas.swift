import SwiftUI
import WidgetForgeKit

/// The interactive editing surface. Renders the draft layout on a fixed
/// per-family canvas (same dimensions as `PreviewCard`) where cells can be
/// dragged to move, corner-dragged to resize, tapped to configure, and X'd to
/// delete. Empty grid slots show a "+" to add a cell there. All placement
/// decisions defer to `CanvasEditIntent`; the parent applies the mutations.
struct EditorCanvas: View {
    let layout: WidgetLayout
    var onReflow: ([Cell]) -> Void
    var onResizeCell: (Cell.ID, GridSize) -> Void
    var onDeleteCell: (Cell.ID) -> Void
    var onTapCell: (Cell.ID) -> Void
    var onTapEmptySlot: (GridPoint) -> Void

    @State private var manifests: [AppCapabilityManifest] = []
    // Live gesture state for the cell currently being manipulated.
    @State private var dragOffset: CGSize = .zero
    @State private var resizeTranslation: CGSize = .zero
    @State private var activeCellId: Cell.ID?
    // Pixel top-left of the dragged cell at the moment the drag began. The cell
    // follows the finger from this fixed anchor, independent of its grid origin
    // (which mutates live as reflow pushes it to the hovered slot).
    @State private var dragAnchor: CGPoint = .zero
    // Last slot we reflowed to, so we only re-pack when the finger crosses into
    // a new grid cell (not on every pixel of movement).
    @State private var lastReflowTarget: GridPoint?

    var body: some View {
        GeometryReader { geo in
            let geom = GridGeometry(family: layout.family, size: geo.size)
            ZStack(alignment: .topLeading) {
                background
                emptySlots(geom)
                ForEach(layout.cells) { cell in
                    cellView(cell, geom: geom)
                }
            }
        }
        .frame(width: canvasWidth, height: canvasHeight)
        .coordinateSpace(name: "canvas")
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(DesignSystem.cardStroke, lineWidth: 1))
        .widgetTheme(theme)
        .task { manifests = SampleData.merged(withReal: ManifestStore().readAll()) }
    }

    /// Resolved theme for the layout being edited (drives cell + canvas look).
    private var theme: WidgetTheme { ThemeCatalog.theme(id: layout.themeId) }

    // MARK: Layers

    @ViewBuilder
    private var background: some View {
        switch layout.background {
        case .system:
            ThemeBackgroundView(theme.background)
        case .accentHex(let hex): DesignSystem.color(fromHex: hex)
        case .clear: Color.clear
        }
    }

    @ViewBuilder
    private func emptySlots(_ geom: GridGeometry) -> some View {
        let occ = occupancy()
        ForEach(0..<layout.family.rows, id: \.self) { row in
            ForEach(0..<layout.family.cols, id: \.self) { col in
                if !occ[row][col] {
                    let frame = geom.pixelFrame(origin: GridPoint(col: col, row: row),
                                                span: GridSize(cols: 1, rows: 1))
                    Button { onTapEmptySlot(GridPoint(col: col, row: row)) } label: {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                            .foregroundStyle(Color.preferredColor(.tertiaryLabel))
                            .overlay(Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.preferredColor(.tertiaryLabel)))
                    }
                    .buttonStyle(.plain)
                    .frame(width: frame.width - 4, height: frame.height - 4)
                    .offset(x: frame.minX + 2, y: frame.minY + 2)
                }
            }
        }
    }

    @ViewBuilder
    private func cellView(_ cell: Cell, geom: GridGeometry) -> some View {
        let base = geom.pixelFrame(origin: cell.origin, span: cell.span)
        let isActive = activeCellId == cell.id
        // Live footprint while resizing.
        let liveSpan = isActive && resizeTranslation != .zero
            ? CanvasEditIntent.resize(cell: cell, delta: geom.spanDelta(pixelTranslation: resizeTranslation),
                                      family: layout.family, siblings: layout.cells)
            : cell.span
        let liveFrame = geom.pixelFrame(origin: cell.origin, span: liveSpan)
        let slice = cell.boundBinding.flatMap {
            RenderContext(pool: SlicePool(manifests), registry: .default).slice(for: $0)
        }

        ZStack(alignment: .topLeading) {
            CellContentView(component: cell.component, slice: slice, registry: .default)
                .frame(width: liveFrame.width - 4, height: liveFrame.height - 4)
        }
        .overlay(alignment: .topLeading) {
            // Inset just inside the cell corner (not hung outside at a negative
            // offset) so a cell at grid origin (0,0) is never clipped by the
            // canvas rounded-corner clipShape and the delete target stays tappable.
            DeleteBadge { onDeleteCell(cell.id) }.offset(x: 2, y: 2)
        }
        .overlay(alignment: .bottomTrailing) {
            ResizeHandle()
                .offset(x: -2, y: -2)
                .highPriorityGesture(resizeGesture(cell))
        }
        .frame(width: liveFrame.width - 4, height: liveFrame.height - 4, alignment: .topLeading)
        .offset(x: isActive && dragOffset != .zero ? dragAnchor.x + dragOffset.width : base.minX + 2,
                y: isActive && dragOffset != .zero ? dragAnchor.y + dragOffset.height : base.minY + 2)
        .scaleEffect(isActive && dragOffset != .zero ? 1.05 : 1.0)
        .shadow(radius: isActive && dragOffset != .zero ? 8 : 0)
        .zIndex(isActive ? 1 : 0)
        // Non-dragged cells slide smoothly to the slots reflow assigns them,
        // creating the live "make a hole" feel. The dragged cell tracks the
        // finger 1:1 (no animation lag) so only its neighbours animate.
        .animation(isActive ? nil : .spring(response: 0.28, dampingFraction: 0.72), value: base.minX)
        .animation(isActive ? nil : .spring(response: 0.28, dampingFraction: 0.72), value: base.minY)
        .onTapGesture { onTapCell(cell.id) }
        .gesture(moveGesture(cell, geom: geom))
    }

    // MARK: Gestures

    private func moveGesture(_ cell: Cell, geom: GridGeometry) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                if activeCellId != cell.id {
                    // Drag just began: anchor the cell at its current pixel spot
                    // so it can follow the finger even as reflow moves its origin.
                    activeCellId = cell.id
                    let start = geom.pixelFrame(origin: cell.origin, span: cell.span)
                    dragAnchor = CGPoint(x: start.minX + 2, y: start.minY + 2)
                    lastReflowTarget = cell.origin
                }
                dragOffset = value.translation
                // Live reflow: figure out which slot the cell's top-left is over
                // right now and, when that crosses into a new slot, push the
                // other cells aside to open a hole (iOS Home Screen behavior).
                let fingerTopLeft = CGSize(width: dragAnchor.x - 2 + value.translation.width,
                                           height: dragAnchor.y - 2 + value.translation.height)
                let target = geom.snappedOrigin(pixelOffset: fingerTopLeft, span: cell.span)
                if target != lastReflowTarget {
                    if let reflowed = CanvasReflow.place(cells: layout.cells, moving: cell.id,
                                                         to: target, family: layout.family) {
                        lastReflowTarget = target
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                            onReflow(reflowed)
                        }
                    }
                }
            }
            .onEnded { _ in
                // The grid was already reorganized live during the drag; just
                // settle the dragged cell into its slot.
                withAnimation(.spring(response: 0.3)) { dragOffset = .zero }
                activeCellId = nil
                lastReflowTarget = nil
            }
    }

    private func resizeGesture(_ cell: Cell) -> some Gesture {
        // Measure in the fixed "canvas" coordinate space, NOT the handle's local
        // space. The handle sits on the corner of the frame being resized, so a
        // local-space drag feeds back on itself (frame grows -> handle moves out
        // from under the finger -> translation shrinks -> frame shrinks), which
        // caused the flicker and the "must hit the exact spot" feel. Canvas-space
        // translation is independent of how the cell grows.
        DragGesture(minimumDistance: 4, coordinateSpace: .named("canvas"))
            .onChanged { value in
                activeCellId = cell.id
                resizeTranslation = value.translation
            }
            .onEnded { _ in
                let geom = GridGeometry(family: layout.family,
                                        size: CGSize(width: canvasWidth, height: canvasHeight))
                let newSpan = CanvasEditIntent.resize(
                    cell: cell, delta: geom.spanDelta(pixelTranslation: resizeTranslation),
                    family: layout.family, siblings: layout.cells)
                if newSpan != cell.span { onResizeCell(cell.id, newSpan) }
                resizeTranslation = .zero
                activeCellId = nil
            }
    }

    // MARK: Helpers

    /// `[row][col]` occupancy grid for empty-slot placement.
    private func occupancy() -> [[Bool]] {
        var grid = Array(repeating: Array(repeating: false, count: layout.family.cols),
                         count: layout.family.rows)
        for cell in layout.cells {
            for r in cell.origin.row..<min(cell.origin.row + cell.span.rows, layout.family.rows) {
                for c in cell.origin.col..<min(cell.origin.col + cell.span.cols, layout.family.cols) {
                    grid[r][c] = true
                }
            }
        }
        return grid
    }

    private var canvasWidth: CGFloat {
        switch layout.family {
        case .small: return 170
        case .medium, .large, .extraLarge, .xlPortrait: return 340
        }
    }
    private var canvasHeight: CGFloat {
        switch layout.family {
        case .small: return 170
        case .medium: return 160
        case .large, .extraLarge: return 340
        case .xlPortrait: return 460
        }
    }
}
