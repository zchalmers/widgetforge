import SwiftUI
import WidgetForgeKit

/// Grid of component kinds shown after tapping an empty "+" slot. Picking a
/// kind hands it to the parent, which opens the config modal for the new cell.
struct TypeGridPicker: View {
    var onPick: (Component.Kind) -> Void
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Component.Kind.allCases, id: \.self) { kind in
                        Button {
                            onPick(kind)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(systemName: kind.symbolName)
                                    .font(.title2)
                                    .foregroundStyle(DesignSystem.suiteAccent)
                                Text(kind.displayName)
                                    .font(.themeKit(forTextStyle: .headline))
                                    .foregroundStyle(.primary)
                                Text(kind.summary)
                                    .font(.themeKit(forTextStyle: .caption1))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(DesignSystem.cardFill))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Add a component")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
