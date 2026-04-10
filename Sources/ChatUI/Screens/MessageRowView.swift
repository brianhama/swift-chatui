import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A single transcript row that composes sender labels, avatar space, bubble content, overlays, and status.
public struct MessageRowView: View {
    @Environment(\.chatTheme) private var theme
    @Environment(\.chatAvatarRenderer) private var avatarRenderer
    @Environment(\.chatMessageAccessoryRenderer) private var accessoryRenderer
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The conversation that owns the message.
    public var conversation: ChatConversation

    /// The message displayed in the row.
    public var message: ChatMessage

    /// The derived row context.
    public var context: MessageRowContext

    /// Thread configuration values.
    public var configuration: ChatThreadConfiguration

    /// Optional retry action for failed messages.
    public var onRetryMessage: ((ChatMessage) -> Void)?

    /// Creates a message row view.
    public init(
        conversation: ChatConversation,
        message: ChatMessage,
        context: MessageRowContext,
        configuration: ChatThreadConfiguration = .messages,
        onRetryMessage: ((ChatMessage) -> Void)? = nil
    ) {
        self.conversation = conversation
        self.message = message
        self.context = context
        self.configuration = configuration
        self.onRetryMessage = onRetryMessage
    }

    public var body: some View {
        rowBody(availableWidth: availableWidth)
            .frame(maxWidth: .infinity, alignment: context.direction == .outgoing ? .trailing : .leading)
    }

    private func rowBody(availableWidth: CGFloat) -> some View {
        let bubbleWidthRatio = availableWidth > 700 ? theme.metrics.bubbleMaxWidthRegular : theme.metrics.bubbleMaxWidthCompact
        let avatarSpace = context.isGroupConversation && context.direction == .incoming ? theme.metrics.transcriptAvatarSize + 8 : 0
        let bubbleMaxWidth = max(160, (availableWidth - avatarSpace - theme.metrics.transcriptHorizontalPadding * 2) * bubbleWidthRatio)

        return VStack(alignment: context.direction == .outgoing ? .trailing : .leading, spacing: 3) {
            if context.showsSenderName, let sender = sender {
                Text(sender.displayName)
                    .font(theme.typography.senderLabel)
                    .foregroundStyle(theme.colors.metadata)
                    .lineLimit(1)
                    .padding(.leading, avatarSpace > 0 ? avatarSpace : 0)
            }

            HStack(alignment: .bottom, spacing: 8) {
                if context.direction == .outgoing {
                    Spacer(minLength: 0)
                }

                if context.direction == .incoming {
                    avatarSlot
                }

                bubbleColumn(maxWidth: bubbleMaxWidth)

                if context.direction == .incoming {
                    Spacer(minLength: 0)
                }
            }
        }
        .contextMenu { contextMenuContent }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(accessibilityLabel))
    }

    @ViewBuilder
    private func bubbleColumn(maxWidth: CGFloat) -> some View {
        VStack(alignment: context.direction == .outgoing ? .trailing : .leading, spacing: 3) {
            MessageBubbleView(message: message, context: context, maxWidth: maxWidth)

            if context.showsStatus {
                Text(theme.formatters.messageStatus(message.status))
                    .font(theme.typography.status)
                    .foregroundStyle(statusColor)
                    .lineLimit(1)
            }

            if let accessory = accessoryRenderer.render(message: message, context: context) {
                accessory
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var avatarSlot: some View {
        if context.isGroupConversation {
            if context.showsAvatar, let sender {
                avatarRenderer.render(participant: sender, size: theme.metrics.transcriptAvatarSize)
            } else {
                Color.clear
                    .frame(width: theme.metrics.transcriptAvatarSize, height: theme.metrics.transcriptAvatarSize)
            }
        }
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        #if canImport(UIKit)
        if case let .text(text) = message.content {
            Button {
                UIPasteboard.general.string = text
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
        #endif

        if case .failed = message.status, let onRetryMessage {
            Button {
                onRetryMessage(message)
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
            }
        }

        ForEach(configuration.messageContextMenuActions(message, context)) { action in
            Button(role: action.role, action: action.action) {
                if let systemImage = action.systemImage {
                    Label(action.title, systemImage: systemImage)
                } else {
                    Text(action.title)
                }
            }
        }
    }

    private var sender: ChatParticipant? {
        conversation.participants.first(where: { $0.id == message.senderID })
    }

    private var statusColor: Color {
        if case .failed = message.status {
            return theme.colors.destructive
        }
        return theme.colors.metadata
    }

    private var availableWidth: CGFloat {
        #if canImport(UIKit)
        let screenWidth = UIScreen.main.bounds.width
        #elseif canImport(AppKit)
        let screenWidth = NSScreen.main?.frame.width ?? 390
        #else
        let screenWidth: CGFloat = 390
        #endif
        let sidePadding = theme.metrics.transcriptHorizontalPadding * 2
        switch horizontalSizeClass {
        case .regular:
            return max(320, screenWidth - sidePadding - 80)
        default:
            return max(240, screenWidth - sidePadding)
        }
    }

    private var accessibilityLabel: String {
        let senderName = sender?.accessibilityName ?? sender?.displayName ?? "Unknown sender"
        let timestamp = message.timestamp.formatted(.dateTime.hour().minute())
        let contentSummary: String
        switch message.content {
        case let .text(text):
            contentSummary = text
        case .image:
            contentSummary = "Image"
        case .video:
            contentSummary = "Video"
        case .audio:
            contentSummary = "Audio"
        case let .custom(type, summary):
            contentSummary = summary ?? type
        }

        let status = context.showsStatus ? ", \(theme.formatters.messageStatus(message.status))" : ""
        return "\(senderName), \(timestamp), \(contentSummary)\(status)"
    }
}

#Preview("Failed Outgoing") {
    ZStack(alignment: .topLeading) {
        ChatTheme.messages.colors.transcriptBackground

        VStack(spacing: 0) {
            MessageRowView(
                conversation: ChatPreviewFixtures.groupConversation,
                message: ChatPreviewFixtures.failedMessage,
                context: MessageRowContext(
                    direction: .outgoing,
                    groupPosition: .single,
                    showsAvatar: false,
                    showsSenderName: false,
                    showsStatus: true,
                    isGroupConversation: true
                ),
                onRetryMessage: { _ in }
            )
            .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, ChatMetrics.messages.transcriptHorizontalPadding)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }
    .chatTheme(.messages)
}

#Preview("Emoji Only") {
    ZStack(alignment: .topLeading) {
        ChatTheme.messages.colors.transcriptBackground

        VStack(spacing: 0) {
            MessageRowView(
                conversation: ChatPreviewFixtures.directConversation,
                message: ChatPreviewFixtures.emojiMessage,
                context: MessageRowContext(
                    direction: .incoming,
                    groupPosition: .single,
                    showsAvatar: false,
                    showsSenderName: false,
                    showsStatus: false,
                    isGroupConversation: false
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, ChatMetrics.messages.transcriptHorizontalPadding)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }
    .chatTheme(.messages)
}
