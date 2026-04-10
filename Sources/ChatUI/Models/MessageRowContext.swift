import Foundation

/// The visual direction of a message row.
public enum MessageDirection: Hashable, Sendable {
    /// A message from another participant.
    case incoming

    /// A message from the current user.
    case outgoing
}

/// The position of a message within a visual run.
public enum MessageGroupPosition: Hashable, Sendable {
    /// The run contains a single message.
    case single

    /// The first message in a multi-message run.
    case first

    /// A middle message in a run.
    case middle

    /// The final message in a run.
    case last
}

/// Derived row presentation metadata passed to renderers.
public struct MessageRowContext: Hashable, Sendable {
    /// The incoming or outgoing direction.
    public let direction: MessageDirection

    /// The message's position within its visual run.
    public let groupPosition: MessageGroupPosition

    /// Whether an avatar should be shown for the row.
    public let showsAvatar: Bool

    /// Whether a sender label should be shown above the row.
    public let showsSenderName: Bool

    /// Whether message status text should be shown below the row.
    public let showsStatus: Bool

    /// Whether the conversation is a group conversation.
    public let isGroupConversation: Bool

    /// Creates a row context.
    public init(
        direction: MessageDirection,
        groupPosition: MessageGroupPosition,
        showsAvatar: Bool,
        showsSenderName: Bool,
        showsStatus: Bool,
        isGroupConversation: Bool
    ) {
        self.direction = direction
        self.groupPosition = groupPosition
        self.showsAvatar = showsAvatar
        self.showsSenderName = showsSenderName
        self.showsStatus = showsStatus
        self.isGroupConversation = isGroupConversation
    }
}
