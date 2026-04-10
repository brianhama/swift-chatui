import SwiftUI

/// A multiline message composer with optional accessory slots.
public struct MessageComposerView: View {
    @Environment(\.chatTheme) private var theme
    @FocusState private var isFocused: Bool

    /// The bound draft text.
    @Binding public var text: String

    /// Composer-specific configuration.
    public var configuration: MessageComposerConfiguration

    /// An optional leading accessory view.
    public var leadingAccessory: AnyView?

    /// An optional trailing accessory view.
    public var trailingAccessory: AnyView?

    /// The send action for non-empty text.
    public var onSendText: (String) -> Void

    /// Creates a message composer view.
    public init(
        text: Binding<String>,
        configuration: MessageComposerConfiguration = .messages,
        leadingAccessory: AnyView? = nil,
        trailingAccessory: AnyView? = nil,
        onSendText: @escaping (String) -> Void
    ) {
        self._text = text
        self.configuration = configuration
        self.leadingAccessory = leadingAccessory
        self.trailingAccessory = trailingAccessory
        self.onSendText = onSendText
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if let leadingAccessory {
                leadingAccessory
            }

            HStack(alignment: .bottom, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if trimmedText.isEmpty {
                        Text(configuration.placeholder)
                            .font(theme.typography.composer)
                            .foregroundStyle(theme.colors.metadata)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .allowsHitTesting(false)
                    }

                    TextField("", text: $text, axis: .vertical)
                        .font(theme.typography.composer)
                        .lineLimit(1...configuration.maxVisibleLines)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .frame(minHeight: theme.metrics.composerFieldMinHeight, alignment: .leading)
                        .focused($isFocused)
                }
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(theme.colors.composerFieldBackground)
                )

                if let trailingAccessory {
                    trailingAccessory
                }

                Button(action: send) {
                    Image(systemName: configuration.sendSymbolName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(theme.colors.outgoingText)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(sendButtonFill))
                }
                .buttonStyle(.plain)
                .disabled(trimmedText.isEmpty)
                .accessibilityLabel(Text("Send"))
            }
        }
        .padding(.horizontal, theme.metrics.transcriptHorizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(theme.colors.composerBackground)
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var sendButtonFill: Color {
        trimmedText.isEmpty ? theme.colors.metadata.opacity(0.25) : theme.colors.accent
    }

    private func send() {
        let outgoingText = trimmedText
        guard outgoingText.isEmpty == false else {
            return
        }

        onSendText(outgoingText)
        text = ""
    }
}

#Preview("Composer") {
    struct ComposerPreview: View {
        @State private var text = "Here is a long enough draft to show growth."

        var body: some View {
            MessageComposerView(text: $text) { _ in }
                .chatTheme(.messages)
        }
    }

    return ComposerPreview()
}
