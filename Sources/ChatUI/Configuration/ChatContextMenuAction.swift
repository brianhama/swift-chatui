import SwiftUI

/// A host-supplied context menu action for a message row.
public struct ChatContextMenuAction: Identifiable {
    /// The stable action identifier.
    public let id: String

    /// The displayed action title.
    public var title: String

    /// The optional SF Symbol name.
    public var systemImage: String?

    /// The button role used when rendered in menus.
    public var role: ButtonRole?

    /// The action handler.
    public var action: () -> Void

    /// Creates a context menu action.
    public init(
        id: String,
        title: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }
}
