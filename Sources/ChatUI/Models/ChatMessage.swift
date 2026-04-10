import Foundation

/// A message rendered in a transcript.
public struct ChatMessage: Identifiable, Hashable, Sendable {
    /// The stable message identifier.
    public let id: String

    /// The owning conversation identifier.
    public var conversationID: ChatConversation.ID

    /// The sender identifier.
    public var senderID: ChatParticipant.ID

    /// The message timestamp.
    public var timestamp: Date

    /// The message content.
    public var content: MessageContent

    /// The delivery or read status.
    public var status: MessageStatus

    /// Reactions attached to the message.
    public var reactions: [MessageReaction]

    /// Whether the message has been edited.
    public var isEdited: Bool

    /// Creates a chat message.
    public init(
        id: String,
        conversationID: ChatConversation.ID,
        senderID: ChatParticipant.ID,
        timestamp: Date,
        content: MessageContent,
        status: MessageStatus = .sent,
        reactions: [MessageReaction] = [],
        isEdited: Bool = false
    ) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.timestamp = timestamp
        self.content = content
        self.status = status
        self.reactions = reactions
        self.isEdited = isEdited
    }
}
