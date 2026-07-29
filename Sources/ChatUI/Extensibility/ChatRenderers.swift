import SwiftUI

/// Type-erased avatar renderer used by the environment.
public struct ChatAvatarRenderer: Sendable {
    private let renderClosure: @MainActor @Sendable (ChatParticipant, CGFloat) -> AnyView

    /// Creates an avatar renderer.
    public init<Content: View>(@ViewBuilder render: @escaping @MainActor @Sendable (ChatParticipant, CGFloat) -> Content) {
        self.renderClosure = { participant, size in
            AnyView(render(participant, size))
        }
    }

    @MainActor
    func render(participant: ChatParticipant, size: CGFloat) -> AnyView {
        renderClosure(participant, size)
    }
}

/// Type-erased group avatar renderer used by the environment.
public struct ChatGroupAvatarRenderer: Sendable {
    private let renderClosure: @MainActor @Sendable ([ChatParticipant], CGFloat) -> AnyView

    /// Creates a group avatar renderer.
    public init<Content: View>(@ViewBuilder render: @escaping @MainActor @Sendable ([ChatParticipant], CGFloat) -> Content) {
        self.renderClosure = { participants, size in
            AnyView(render(participants, size))
        }
    }

    @MainActor
    func render(participants: [ChatParticipant], size: CGFloat) -> AnyView {
        renderClosure(participants, size)
    }
}

/// Type-erased message content renderer used by the environment.
public struct MessageContentRenderer: Sendable {
    private let renderClosure: @MainActor @Sendable (ChatMessage, MessageRowContext) -> AnyView?

    /// Creates a message content renderer.
    public init<Content: View>(render: @escaping @MainActor @Sendable (ChatMessage, MessageRowContext) -> Content?) {
        self.renderClosure = { message, context in
            render(message, context).map { AnyView($0) }
        }
    }

    @MainActor
    func render(message: ChatMessage, context: MessageRowContext) -> AnyView? {
        renderClosure(message, context)
    }
}

/// Type-erased message overlay renderer used by the environment.
public struct MessageOverlayRenderer: Sendable {
    private let renderClosure: @MainActor @Sendable (ChatMessage, MessageRowContext) -> AnyView?

    /// Creates a message overlay renderer.
    public init<Content: View>(render: @escaping @MainActor @Sendable (ChatMessage, MessageRowContext) -> Content?) {
        self.renderClosure = { message, context in
            render(message, context).map { AnyView($0) }
        }
    }

    @MainActor
    func render(message: ChatMessage, context: MessageRowContext) -> AnyView? {
        renderClosure(message, context)
    }
}

/// Type-erased message accessory renderer used by the environment.
public struct MessageAccessoryRenderer: Sendable {
    private let renderClosure: @MainActor @Sendable (ChatMessage, MessageRowContext) -> AnyView?

    /// Creates a message accessory renderer.
    public init<Content: View>(render: @escaping @MainActor @Sendable (ChatMessage, MessageRowContext) -> Content?) {
        self.renderClosure = { message, context in
            render(message, context).map { AnyView($0) }
        }
    }

    @MainActor
    func render(message: ChatMessage, context: MessageRowContext) -> AnyView? {
        renderClosure(message, context)
    }
}

/// Type-erased conversation row accessory renderer used by the environment.
public struct ConversationRowAccessoryRenderer: Sendable {
    private let renderClosure: @MainActor @Sendable (ConversationPreview) -> AnyView?

    /// Creates a conversation row accessory renderer.
    public init<Content: View>(render: @escaping @MainActor @Sendable (ConversationPreview) -> Content?) {
        self.renderClosure = { preview in
            render(preview).map { AnyView($0) }
        }
    }

    @MainActor
    func render(preview: ConversationPreview) -> AnyView? {
        renderClosure(preview)
    }
}

/// Type-erased header renderer used by the environment.
public struct ChatHeaderRenderer: Sendable {
    private let renderClosure: @MainActor @Sendable (ChatConversation) -> AnyView?

    /// Creates a header renderer.
    public init<Content: View>(render: @escaping @MainActor @Sendable (ChatConversation) -> Content?) {
        self.renderClosure = { conversation in
            render(conversation).map { AnyView($0) }
        }
    }

    @MainActor
    func render(conversation: ChatConversation) -> AnyView? {
        renderClosure(conversation)
    }
}

/// Type-erased typing indicator renderer used by the environment.
public struct TypingIndicatorRenderer: Sendable {
    private let renderClosure: @MainActor @Sendable ([TypingParticipant], [ChatParticipant]) -> AnyView?

    /// Creates a typing indicator renderer.
    public init<Content: View>(render: @escaping @MainActor @Sendable ([TypingParticipant], [ChatParticipant]) -> Content?) {
        self.renderClosure = { typers, participants in
            render(typers, participants).map { AnyView($0) }
        }
    }

    @MainActor
    func render(typingParticipants: [TypingParticipant], participants: [ChatParticipant]) -> AnyView? {
        renderClosure(typingParticipants, participants)
    }
}

private struct ChatThemeKey: EnvironmentKey {
    static let defaultValue: ChatTheme = .messages
}

private struct ChatAvatarRendererKey: EnvironmentKey {
    static let defaultValue = ChatAvatarRenderer { participant, size in
        AvatarView(participant: participant, size: size)
    }
}

private struct ChatGroupAvatarRendererKey: EnvironmentKey {
    static let defaultValue = ChatGroupAvatarRenderer { participants, size in
        GroupAvatarView(participants: participants, size: size)
    }
}

private struct MessageContentRendererKey: EnvironmentKey {
    static let defaultValue = MessageContentRenderer { _, _ in nil as EmptyView? }
}

private struct MessageOverlayRendererKey: EnvironmentKey {
    static let defaultValue = MessageOverlayRenderer { _, _ in nil as EmptyView? }
}

private struct MessageAccessoryRendererKey: EnvironmentKey {
    static let defaultValue = MessageAccessoryRenderer { _, _ in nil as EmptyView? }
}

private struct ConversationRowAccessoryRendererKey: EnvironmentKey {
    static let defaultValue = ConversationRowAccessoryRenderer { _ in nil as EmptyView? }
}

private struct ChatHeaderRendererKey: EnvironmentKey {
    static let defaultValue = ChatHeaderRenderer { _ in nil as EmptyView? }
}

private struct TypingIndicatorRendererKey: EnvironmentKey {
    static let defaultValue = TypingIndicatorRenderer { _, _ in nil as EmptyView? }
}

extension EnvironmentValues {
    var chatTheme: ChatTheme {
        get { self[ChatThemeKey.self] }
        set { self[ChatThemeKey.self] = newValue }
    }

    var chatAvatarRenderer: ChatAvatarRenderer {
        get { self[ChatAvatarRendererKey.self] }
        set { self[ChatAvatarRendererKey.self] = newValue }
    }

    var chatGroupAvatarRenderer: ChatGroupAvatarRenderer {
        get { self[ChatGroupAvatarRendererKey.self] }
        set { self[ChatGroupAvatarRendererKey.self] = newValue }
    }

    var chatMessageContentRenderer: MessageContentRenderer {
        get { self[MessageContentRendererKey.self] }
        set { self[MessageContentRendererKey.self] = newValue }
    }

    var chatMessageOverlayRenderer: MessageOverlayRenderer {
        get { self[MessageOverlayRendererKey.self] }
        set { self[MessageOverlayRendererKey.self] = newValue }
    }

    var chatMessageAccessoryRenderer: MessageAccessoryRenderer {
        get { self[MessageAccessoryRendererKey.self] }
        set { self[MessageAccessoryRendererKey.self] = newValue }
    }

    var chatConversationRowAccessoryRenderer: ConversationRowAccessoryRenderer {
        get { self[ConversationRowAccessoryRendererKey.self] }
        set { self[ConversationRowAccessoryRendererKey.self] = newValue }
    }

    var chatHeaderRenderer: ChatHeaderRenderer {
        get { self[ChatHeaderRendererKey.self] }
        set { self[ChatHeaderRendererKey.self] = newValue }
    }

    var chatTypingIndicatorRenderer: TypingIndicatorRenderer {
        get { self[TypingIndicatorRendererKey.self] }
        set { self[TypingIndicatorRendererKey.self] = newValue }
    }
}

/// Environment modifiers for chat theme and renderer customization.
public extension View {
    /// Applies a chat theme to the view hierarchy.
    func chatTheme(_ theme: ChatTheme) -> some View {
        environment(\.chatTheme, theme)
    }

    /// Applies a custom avatar renderer to the view hierarchy.
    func chatAvatarRenderer(_ renderer: ChatAvatarRenderer) -> some View {
        environment(\.chatAvatarRenderer, renderer)
    }

    /// Applies a custom group avatar renderer to the view hierarchy.
    func chatGroupAvatarRenderer(_ renderer: ChatGroupAvatarRenderer) -> some View {
        environment(\.chatGroupAvatarRenderer, renderer)
    }

    /// Applies a custom message content renderer to the view hierarchy.
    func chatMessageContentRenderer(_ renderer: MessageContentRenderer) -> some View {
        environment(\.chatMessageContentRenderer, renderer)
    }

    /// Applies a custom message overlay renderer to the view hierarchy.
    func chatMessageOverlayRenderer(_ renderer: MessageOverlayRenderer) -> some View {
        environment(\.chatMessageOverlayRenderer, renderer)
    }

    /// Applies a custom message accessory renderer to the view hierarchy.
    func chatMessageAccessoryRenderer(_ renderer: MessageAccessoryRenderer) -> some View {
        environment(\.chatMessageAccessoryRenderer, renderer)
    }

    /// Applies a custom conversation row accessory renderer to the view hierarchy.
    func chatConversationRowAccessoryRenderer(_ renderer: ConversationRowAccessoryRenderer) -> some View {
        environment(\.chatConversationRowAccessoryRenderer, renderer)
    }

    /// Applies a custom chat header renderer to the view hierarchy.
    func chatHeaderRenderer(_ renderer: ChatHeaderRenderer) -> some View {
        environment(\.chatHeaderRenderer, renderer)
    }

    /// Applies a custom typing indicator renderer to the view hierarchy.
    func chatTypingIndicatorRenderer(_ renderer: TypingIndicatorRenderer) -> some View {
        environment(\.chatTypingIndicatorRenderer, renderer)
    }
}
