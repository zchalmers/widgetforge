public enum SliceKind: String, Codable, Sendable, CaseIterable {
    case count
    case list
    case metric
    case status
    case progress
}
