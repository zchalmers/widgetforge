import SwiftUI
import WidgetForgeKit

/// A small circular "remove" button shown at a cell's top-left in edit mode,
/// mirroring the iOS Home Screen delete affordance.
struct DeleteBadge: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.black.opacity(0.55)))
                .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

/// Bottom-right resize grabber. Visual only; the owning view attaches the drag
/// gesture and sizes the hit area.
struct ResizeHandle: View {
    var body: some View {
        Image(systemName: "arrow.down.right")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 22, height: 22)
            .background(Circle().fill(DesignSystem.suiteAccent))
            .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1))
    }
}
