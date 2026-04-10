import SwiftUI

/// A centered transcript date separator.
public struct DateSeparatorView: View {
    @Environment(\.chatTheme) private var theme

    /// The display label for the separator.
    public var title: String

    /// Creates a date separator view.
    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(theme.typography.dateSeparator)
            .foregroundStyle(theme.colors.metadata)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(.isStaticText)
    }
}

#Preview("Date Separator") {
    DateSeparatorView(title: "Today")
        .chatTheme(.messages)
        .padding()
}
