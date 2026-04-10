import Foundation

/// Rules that control when transcript date separators are inserted.
public enum DateSeparatorStrategy: Hashable, Sendable {
    /// Insert separators only when the calendar day changes.
    case dayChange

    /// Insert separators on day change and after large gaps.
    case dayChangeAndLargeGap(TimeInterval)
}
