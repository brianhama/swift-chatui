import CoreGraphics
import Foundation

/// A sendable size wrapper used by attachment models.
public struct CGSizeCodable: Hashable, Codable, Sendable {
    /// The width component.
    public var width: CGFloat

    /// The height component.
    public var height: CGFloat

    /// Creates a size wrapper.
    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
}
