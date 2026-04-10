import Foundation

/// List-specific preview data for a conversation row.
public struct ConversationPreview: Identifiable, Hashable, Sendable {
    /// The stable preview identifier.
    public let id: String

    /// The participants shown in the row.
    public var participants: [ChatParticipant]

    /// An optional host-provided explicit title.
    public var explicitTitle: String?

    /// The preview snippet for the latest message.
    public var latestMessagePreview: String

    /// The timestamp for the latest activity.
    public var latestActivityAt: Date

    /// The unread message count.
    public var unreadCount: Int

    /// Whether the conversation is muted.
    public var isMuted: Bool

    /// Whether the conversation is pinned.
    public var isPinned: Bool

    /// An optional draft snippet shown instead of the latest preview.
    public var draftPreview: String?

    /// Whether the conversation is direct or group-based.
    public var kind: ConversationKind

    /// The current user's participant identifier.
    public var currentUserID: ChatParticipant.ID

    /// Creates a conversation preview.
    public init(
        id: String,
        participants: [ChatParticipant],
        explicitTitle: String? = nil,
        latestMessagePreview: String,
        latestActivityAt: Date,
        unreadCount: Int = 0,
        isMuted: Bool = false,
        isPinned: Bool = false,
        draftPreview: String? = nil,
        kind: ConversationKind,
        currentUserID: ChatParticipant.ID
    ) {
        self.id = id
        self.participants = participants
        self.explicitTitle = explicitTitle
        self.latestMessagePreview = latestMessagePreview
        self.latestActivityAt = latestActivityAt
        self.unreadCount = unreadCount
        self.isMuted = isMuted
        self.isPinned = isPinned
        self.draftPreview = draftPreview
        self.kind = kind
        self.currentUserID = currentUserID
    }
}
