import Foundation
import SwiftUI
import WidgetForgeKit

struct CountSnippetView: View {
    let snapshot: WidgetIntentSliceSnapshot
    var body: some View {
        let count: Int = {
            if case .count(let n) = snapshot.value { return n }
            return 0
        }()
        VStack(alignment: .leading, spacing: 6) {
            Text(snapshot.sliceDisplayName)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(count)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
            Text("in \(snapshot.appDisplayName)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
    }
}

struct ListSnippetView: View {
    let snapshot: WidgetIntentSliceSnapshot
    var body: some View {
        let items: [SliceValue.ListItem] = {
            if case .list(let arr) = snapshot.value { return Array(arr.prefix(4)) }
            return []
        }()
        VStack(alignment: .leading, spacing: 6) {
            Text(snapshot.sliceDisplayName)
                .font(.caption)
                .foregroundStyle(.secondary)
            if items.isEmpty {
                Text("No items.").font(.footnote).foregroundStyle(.secondary)
            } else {
                ForEach(items) { item in
                    HStack(alignment: .firstTextBaseline) {
                        Text(item.title).font(.subheadline).lineLimit(1)
                        Spacer()
                        if let sub = item.subtitle {
                            Text(sub).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }
                }
            }
            Text(snapshot.appDisplayName).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(16)
    }
}

struct StatusSnippetView: View {
    let snapshot: WidgetIntentSliceSnapshot
    var body: some View {
        let (label, text): (String, String) = {
            if case .status(let st, let t) = snapshot.value {
                switch st {
                case .ok: return ("OK", t)
                case .warning: return ("Warning", t)
                case .critical: return ("Critical", t)
                }
            }
            return ("—", "")
        }()
        VStack(alignment: .leading, spacing: 6) {
            Text(snapshot.sliceDisplayName).font(.caption).foregroundStyle(.secondary)
            Text(label).font(.title2.weight(.semibold))
            Text(text).font(.footnote).foregroundStyle(.secondary)
            Text(snapshot.appDisplayName).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(16)
    }
}

struct MetricSnippetView: View {
    let snapshot: WidgetIntentSliceSnapshot
    var body: some View {
        let (val, unit, trendSymbol): (String, String, String) = {
            if case .metric(let v, let u, let t) = snapshot.value {
                let arrow: String
                switch t {
                case .some(.up): arrow = "↑"
                case .some(.down): arrow = "↓"
                case .some(.flat): arrow = "→"
                case .none: arrow = ""
                }
                return (String(format: "%g", v), u ?? "", arrow)
            }
            return ("—", "", "")
        }()
        VStack(alignment: .leading, spacing: 6) {
            Text(snapshot.sliceDisplayName).font(.caption).foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(val).font(.system(size: 36, weight: .bold, design: .rounded))
                if !unit.isEmpty { Text(unit).font(.headline).foregroundStyle(.secondary) }
                if !trendSymbol.isEmpty { Text(trendSymbol).font(.headline) }
            }
            Text(snapshot.appDisplayName).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(16)
    }
}

struct ProgressSnippetView: View {
    let snapshot: WidgetIntentSliceSnapshot
    var body: some View {
        let (fraction, label): (Double, String) = {
            if case .progress(let f, let l) = snapshot.value {
                return (min(1, max(0, f)), l)
            }
            return (0, "")
        }()
        VStack(alignment: .leading, spacing: 8) {
            Text(label.isEmpty ? snapshot.sliceDisplayName : label)
                .font(.caption).foregroundStyle(.secondary)
            ProgressView(value: fraction)
            Text("\(Int((fraction * 100).rounded()))% · \(snapshot.appDisplayName)")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(16)
    }
}
