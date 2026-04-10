import Foundation

/// Conversation metadata used to render a thread.
public struct ChatConversation: Identifiable, Hashable, Sendable {
    /// The stable conversation identifier.
    public let id: String

    /// Whether the conversation is direct or group-based.
    public var kind: ConversationKind

    /// An optional host-provided explicit title.
    public var explicitTitle: String?

    /// The participants in the conversation.
    public var participants: [ChatParticipant]

    /// The current user's participant identifier.
    public var currentUserID: ChatParticipant.ID

    /// Creates conversation metadata.
    public init(
        id: String,
        kind: ConversationKind,
        explicitTitle: String? = nil,
        participants: [ChatParticipant],
        currentUserID: ChatParticipant.ID
    ) {
        self.id = id
        self.kind = kind
        self.explicitTitle = explicitTitle
        self.participants = participants
        self.currentUserID = currentUserID
    }
}
