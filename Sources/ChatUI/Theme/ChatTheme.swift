import SwiftUI

/// A full visual theme for the chat package.
public struct ChatTheme {
    /// Timing and curve values used by animated elements.
    public struct Animations {
        /// Standard spring animation for UI state changes.
        public var standard: Animation

        /// Animation used by typing dots.
        public var typing: Animation

        /// Creates animation values.
        public init(standard: Animation, typing: Animation) {
            self.standard = standard
            self.typing = typing
        }

        /// Default Messages-inspired animation values.
        public static let messages = Animations(
            standard: .snappy(duration: 0.28),
            typing: .easeInOut(duration: 0.75).repeatForever(autoreverses: true)
        )
    }

    /// Semantic colors.
    public var colors: ChatColors

    /// Typography values.
    public var typography: ChatTypography

    /// Layout metrics.
    public var metrics: ChatMetrics

    /// Animation values.
    public var animations: Animations

    /// Formatter hooks.
    public var formatters: ChatFormatters

    /// Creates a chat theme.
    public init(
        colors: ChatColors,
        typography: ChatTypography,
        metrics: ChatMetrics,
        animations: Animations,
        formatters: ChatFormatters
    ) {
        self.colors = colors
        self.typography = typography
        self.metrics = metrics
        self.animations = animations
        self.formatters = formatters
    }

    /// The default Messages-inspired theme.
    public static let messages = ChatTheme(
        colors: .messages,
        typography: .messages,
        metrics: .messages,
        animations: .messages,
        formatters: .messages
    )
}
