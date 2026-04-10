import Foundation

/// An image attachment placeholder model.
public struct ImageAttachment: Hashable, Sendable {
    /// The optional host-provided URL for the attachment.
    public var url: URL?

    /// The optional display size hint.
    public var size: CGSizeCodable?

    /// Creates an image attachment.
    public init(url: URL? = nil, size: CGSizeCodable? = nil) {
        self.url = url
        self.size = size
    }
}

/// A video attachment placeholder model.
public struct VideoAttachment: Hashable, Sendable {
    /// The optional host-provided URL for the attachment.
    public var url: URL?

    /// A human-readable duration hint.
    public var durationText: String?

    /// Creates a video attachment.
    public init(url: URL? = nil, durationText: String? = nil) {
        self.url = url
        self.durationText = durationText
    }
}

/// An audio attachment placeholder model.
public struct AudioAttachment: Hashable, Sendable {
    /// The optional host-provided URL for the attachment.
    public var url: URL?

    /// A human-readable duration hint.
    public var durationText: String?

    /// Creates an audio attachment.
    public init(url: URL? = nil, durationText: String? = nil) {
        self.url = url
        self.durationText = durationText
    }
}

/// The supported message payloads.
public enum MessageContent: Hashable, Sendable {
    /// Plain text message content.
    case text(String)

    /// Image content scaffold.
    case image(ImageAttachment)

    /// Video content scaffold.
    case video(VideoAttachment)

    /// Audio content scaffold.
    case audio(AudioAttachment)

    /// Host-defined custom content scaffold.
    case custom(type: String, summary: String?)
}
