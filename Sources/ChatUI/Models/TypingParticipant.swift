import Foundation

/// A participant that is currently typing.
public struct TypingParticipant: Identifiable, Hashable, Sendable {
    /// The stable typing session identifier.
    public let id: String

    /// The participant that is typing.
    public var participantID: ChatParticipant.ID

    /// The time the typing indication began.
    public var startedAt: Date

    /// Creates a typing participant model.
    public init(id: String, participantID: ChatParticipant.ID, startedAt: Date) {
        self.id = id
        self.participantID = participantID
        self.startedAt = startedAt
    }
}
