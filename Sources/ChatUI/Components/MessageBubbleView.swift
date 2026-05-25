import SwiftUI

/// A themed message bubble that renders built-in text content and content fallbacks.
public struct MessageBubbleView: View {
    @Environment(\.chatTheme) private var theme
    @Environment(\.chatMessageContentRenderer) private var customContentRenderer
    @Environment(\.chatMessageOverlayRenderer) private var customOverlayRenderer

    /// The message displayed by the bubble.
    public var message: ChatMessage

    /// The derived layout context.
    public var context: MessageRowContext

    /// The maximum width available to the bubble.
    public var maxWidth: CGFloat

    /// Creates a message bubble view.
    public init(message: ChatMessage, context: MessageRowContext, maxWidth: CGFloat) {
        self.message = message
        self.context = context
        self.maxWidth = maxWidth
    }

    public var body: some View {
        TailAlignedBubbleLayout(
            maxWidth: maxWidth,
            direction: context.direction,
            tailInset: showsTail ? MessageBubbleShape.tailInset : 0
        ) {
            bubbleContent
                .font(theme.typography.bubble)
                .foregroundStyle(textColor)
                .multilineTextAlignment(textAlignment)
                .fixedSize(horizontal: false, vertical: true)
                .padding(bubbleContentInsets)
                .background(
                    MessageBubbleShape(
                        direction: context.direction,
                        groupPosition: context.groupPosition,
                        cornerRadius: theme.metrics.bubbleCornerRadius,
                        groupedInnerCornerRadius: theme.metrics.groupedInnerCornerRadius
                    )
                    .fill(bubbleFill)
                )
                .overlay(alignment: overlayAlignment) {
                    if let overlay = overlayContent {
                        overlay.offset(y: 15)
                    }
                }
        }
        .frame(maxWidth: maxWidth, alignment: bubbleAlignment)
        .accessibilityElement(children: .combine)
    }

    private var bubbleContent: some View {
        Group {
            if let content = customContentRenderer.render(message: message, context: context) {
                content
            } else {
                DefaultMessageContentView(message: message)
            }
        }
    }

    private var overlayContent: AnyView? {
        if let customOverlay = customOverlayRenderer.render(message: message, context: context) {
            return customOverlay
        }

        guard message.reactions.isEmpty == false else {
            return nil
        }

        return AnyView(DefaultReactionOverlayView(message: message, direction: context.direction))
    }

    private var bubbleFill: Color {
        context.direction == .outgoing ? theme.colors.outgoingBubble : theme.colors.incomingBubble
    }

    private var textColor: Color {
        context.direction == .outgoing ? theme.colors.outgoingText : theme.colors.incomingText
    }

    private var bubbleAlignment: Alignment {
        context.direction == .outgoing ? .trailing : .leading
    }

    private var overlayAlignment: Alignment {
        context.direction == .outgoing ? .bottomTrailing : .bottomLeading
    }

    private var textAlignment: TextAlignment {
        context.direction == .outgoing ? .trailing : .leading
    }

    private var showsTail: Bool {
        context.groupPosition == .single || context.groupPosition == .last
    }

    private var bubbleContentInsets: EdgeInsets {
        let horizontalPadding: CGFloat = 14
        let verticalPadding: CGFloat = 10
        let tailPadding = showsTail ? MessageBubbleShape.tailInset : 0

        switch context.direction {
        case .incoming:
            return EdgeInsets(
                top: verticalPadding,
                leading: horizontalPadding + tailPadding,
                bottom: verticalPadding,
                trailing: horizontalPadding
            )
        case .outgoing:
            return EdgeInsets(
                top: verticalPadding,
                leading: horizontalPadding,
                bottom: verticalPadding,
                trailing: horizontalPadding + tailPadding
            )
        }
    }
}

private struct TailAlignedBubbleLayout: Layout {
    let maxWidth: CGFloat
    let direction: MessageDirection
    let tailInset: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else {
            return .zero
        }

        let availableBodyWidth = min(maxWidth, proposal.width ?? maxWidth)
        let fittedSize = subview.sizeThatFits(
            ProposedViewSize(width: availableBodyWidth + tailInset, height: proposal.height)
        )

        return CGSize(
            width: max(0, fittedSize.width - tailInset),
            height: fittedSize.height
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard let subview = subviews.first else {
            return
        }

        let availableWidth = min(maxWidth, bounds.width > 0 ? bounds.width : maxWidth)
        let fittedSize = subview.sizeThatFits(
            ProposedViewSize(width: availableWidth + tailInset, height: proposal.height)
        )

        let x = direction == .incoming ? bounds.minX - tailInset : bounds.minX
        subview.place(
            at: CGPoint(x: x, y: bounds.minY),
            proposal: ProposedViewSize(width: fittedSize.width, height: fittedSize.height)
        )
    }
}

private struct DefaultMessageContentView: View {
    let message: ChatMessage

    var body: some View {
        switch message.content {
        case let .text(text):
            Text(text)
                .textSelection(.enabled)
        case .image:
            UnsupportedContentView(symbol: "photo", title: "Image")
        case .video:
            UnsupportedContentView(symbol: "video", title: "Video")
        case .audio:
            UnsupportedContentView(symbol: "waveform", title: "Audio")
        case let .custom(type, summary):
            UnsupportedContentView(symbol: "shippingbox", title: summary ?? type.capitalized)
        }
    }
}

private struct UnsupportedContentView: View {
    let symbol: String
    let title: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.callout)
    }
}

private struct DefaultReactionOverlayView: View {
    @Environment(\.chatTheme) private var theme

    let message: ChatMessage
    let direction: MessageDirection

    private let aggregates = ReactionAggregator()

    var body: some View {
        HStack(spacing: 4) {
            ForEach(aggregates.aggregate(message.reactions), id: \.self) { aggregate in
                HStack(spacing: 2) {
                    Text(aggregate.emoji)
                    if aggregate.count > 1 {
                        Text("\(aggregate.count)")
                    }
                }
            }
        }
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        )
        .overlay(
            Capsule()
                .strokeBorder(theme.colors.incomingBubble, lineWidth: 0.5)
        )
    }
}

#Preview("Outgoing Bubble") {
    MessageBubbleView(
        message: ChatPreviewFixtures.directMessages.last!,
        context: MessageRowContext(
            direction: .outgoing,
            groupPosition: .single,
            showsAvatar: false,
            showsSenderName: false,
            showsStatus: true,
            isGroupConversation: false
        ),
        maxWidth: 280
    )
    .chatTheme(.messages)
    .padding()
}

#Preview("Long Incoming Bubble") {
    MessageBubbleView(
        message: ChatPreviewFixtures.groupMessages[1],
        context: MessageRowContext(
            direction: .incoming,
            groupPosition: .first,
            showsAvatar: false,
            showsSenderName: true,
            showsStatus: false,
            isGroupConversation: true
        ),
        maxWidth: 280
    )
    .chatTheme(.messages)
    .padding()
}
