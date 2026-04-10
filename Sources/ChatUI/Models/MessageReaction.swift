import Foundation

/// A reaction applied to a message.
public struct MessageReaction: Identifiable, Hashable, Sendable {
    /// The stable reaction identifier.
    public let id: String

    /// The emoji value.
    public var emoji: String

    /// The participant that added the reaction.
    public var senderID: ChatParticipant.ID

    /// Creates a message reaction.
    public init(id: String, emoji: String, senderID: ChatParticipant.ID) {
        self.id = id
        self.emoji = emoji
        self.senderID = senderID
    }
}
