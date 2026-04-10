import Foundation

/// A participant that can appear in a conversation or thread.
public struct ChatParticipant: Identifiable, Hashable, Sendable {
    /// The stable participant identifier.
    public let id: String

    /// The participant's primary display name.
    public var displayName: String

    /// A shorter display name used when space is constrained.
    public var shortDisplayName: String?

    /// Initials shown in avatar fallbacks.
    public var initials: String?

    /// A VoiceOver-friendly version of the name.
    public var accessibilityName: String?

    /// A semantic accent token used to derive avatar color.
    public var accentColorToken: String?

    /// Creates a participant model.
    public init(
        id: String,
        displayName: String,
        shortDisplayName: String? = nil,
        initials: String? = nil,
        accessibilityName: String? = nil,
        accentColorToken: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.shortDisplayName = shortDisplayName
        self.initials = initials
        self.accessibilityName = accessibilityName
        self.accentColorToken = accentColorToken
    }
}
