import Foundation

/// Delivery and read state for a message.
public enum MessageStatus: Hashable, Sendable {
    /// The message is currently being sent.
    case sending

    /// The message has been sent.
    case sent

    /// The message has been delivered.
    case delivered

    /// The message has been read.
    case read(at: Date?)

    /// The message failed to send.
    case failed(reason: String?)
}
