import Foundation

public extension Cell {
    /// Resolves the deep link for this cell using a documented four-tier fallback.
    /// Tier 1: slice.deepLink for the cell's binding.
    /// Tier 2: "<entry.scheme>://" when the bound bundle has a confirmed registry entry.
    /// Tier 3: DeepLinkBuilder.editor(layoutId:, cellId:) for header cells.
    /// Tier 4: DeepLinkBuilder.recover(kind:, reason: .missingSlice, layoutId:).
    func effectiveDeepLink(pool: SlicePool,
                           registry: AppRegistry,
                           layoutId: UUID,
                           kind: WidgetKind) -> URL {
        if let binding = boundBinding {
            if let slice = pool.slice(for: binding, registry: registry), let url = slice.deepLink {
                return url
            }
            if let entry = registry.entry(for: binding.bundleId),
               entry.confirmed, !entry.scheme.isEmpty,
               let url = URL(string: "\(entry.scheme)://") {
                return url
            }
            return DeepLinkBuilder.recover(kind: kind, reason: .missingSlice, layoutId: layoutId)
        }
        switch component {
        case .header:
            return DeepLinkBuilder.editor(layoutId: layoutId, cellId: id)
        case .appTile(let cfg):
            if let entry = registry.entry(for: cfg.bundleId),
               entry.confirmed, !entry.scheme.isEmpty,
               let url = URL(string: "\(entry.scheme)://") {
                return url
            }
            return DeepLinkBuilder.recover(kind: kind, reason: .missingSlice, layoutId: layoutId)
        default:
            return DeepLinkBuilder.recover(kind: kind, reason: .missingSlice, layoutId: layoutId)
        }
    }

    /// The DataBinding this cell reads, if any. Header and appTile cells have no binding.
    var boundBinding: DataBinding? {
        switch component {
        case .count(let c): return c.binding
        case .metric(let c): return c.binding
        case .status(let c): return c.binding
        case .progress(let c): return c.binding
        case .list(let c): return c.binding
        case .header, .appTile: return nil
        }
    }
}

/// Numeric signal weight for a cell. Higher wins.
public struct SignalPriority: Equatable, Comparable, Sendable {
    public let tier: Int
    public let magnitude: Double
    public let refreshedAt: Date
    public let readingOrder: Int

    public static func < (lhs: SignalPriority, rhs: SignalPriority) -> Bool {
        if lhs.tier != rhs.tier { return lhs.tier < rhs.tier }
        if lhs.magnitude != rhs.magnitude { return lhs.magnitude < rhs.magnitude }
        if lhs.refreshedAt != rhs.refreshedAt { return lhs.refreshedAt < rhs.refreshedAt }
        // Reading order: earlier reading order = higher priority, so invert the comparison.
        return lhs.readingOrder > rhs.readingOrder
    }
}

public extension WidgetLayout {
    /// Chooses the cell with the strongest live signal. See SignalPriority ordering.
    func primaryCell(in pool: SlicePool, registry: AppRegistry = .default) -> Cell? {
        guard !cells.isEmpty else { return nil }
        let ranked = cells.map { cell -> (Cell, SignalPriority) in
            (cell, priority(for: cell, pool: pool, registry: registry, readingOrder: readingOrderIndex(cell: cell)))
        }
        return ranked.max(by: { $0.1 < $1.1 })?.0
    }

    func primaryDeepLink(pool: SlicePool, registry: AppRegistry, kind: WidgetKind) -> URL {
        if let cell = primaryCell(in: pool, registry: registry) {
            return cell.effectiveDeepLink(pool: pool, registry: registry, layoutId: id, kind: kind)
        }
        return DeepLinkBuilder.recover(kind: kind, reason: .missingLayout, layoutId: id)
    }

    private func readingOrderIndex(cell: Cell) -> Int {
        // Row-major reading order, computed from origin coordinates.
        cell.origin.row * 1000 + cell.origin.col
    }

    private func priority(for cell: Cell, pool: SlicePool, registry: AppRegistry, readingOrder: Int) -> SignalPriority {
        let refreshed: Date
        let slice: DataSlice? = cell.boundBinding.flatMap { pool.slice(for: $0, registry: registry) }
        refreshed = slice?.refreshedAt ?? Date(timeIntervalSince1970: 0)
        switch cell.component {
        case .header:
            return SignalPriority(tier: 2, magnitude: 0, refreshedAt: refreshed, readingOrder: readingOrder)
        case .appTile:
            return SignalPriority(tier: 1, magnitude: 0, refreshedAt: refreshed, readingOrder: readingOrder)
        case .count, .metric, .status, .progress, .list:
            guard let value = slice?.value else {
                return SignalPriority(tier: 0, magnitude: 0, refreshedAt: refreshed, readingOrder: readingOrder)
            }
            switch value {
            case .status(.critical, _):
                return SignalPriority(tier: 100, magnitude: 0, refreshedAt: refreshed, readingOrder: readingOrder)
            case .status(.warning, _):
                return SignalPriority(tier: 90, magnitude: 0, refreshedAt: refreshed, readingOrder: readingOrder)
            case .count(let n) where n > 0:
                return SignalPriority(tier: 80, magnitude: Double(n), refreshedAt: refreshed, readingOrder: readingOrder)
            case .progress(let v, _) where v > 0:
                return SignalPriority(tier: 70, magnitude: v, refreshedAt: refreshed, readingOrder: readingOrder)
            case .metric(let v, _, _) where v != 0:
                return SignalPriority(tier: 60, magnitude: abs(v), refreshedAt: refreshed, readingOrder: readingOrder)
            case .list(let items) where !items.isEmpty:
                return SignalPriority(tier: 50, magnitude: Double(items.count), refreshedAt: refreshed, readingOrder: readingOrder)
            case .status(.ok, _):
                return SignalPriority(tier: 40, magnitude: 0, refreshedAt: refreshed, readingOrder: readingOrder)
            default:
                return SignalPriority(tier: 10, magnitude: 0, refreshedAt: refreshed, readingOrder: readingOrder)
            }
        }
    }
}
