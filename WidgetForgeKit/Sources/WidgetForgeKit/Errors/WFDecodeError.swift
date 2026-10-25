public enum WFDecodeError: Error, Equatable, Sendable {
    case unknownDiscriminator(String)
}
