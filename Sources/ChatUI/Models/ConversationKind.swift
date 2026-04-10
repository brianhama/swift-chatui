import Foundation

/// The high-level conversation style.
public enum ConversationKind: Hashable, Sendable {
    /// A one-to-one chat.
    case direct

    /// A multi-participant group chat.
    case group
}
