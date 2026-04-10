import SwiftUI

/// A custom speech-bubble shape with grouping-aware corners and optional tail.
public struct MessageBubbleShape: Shape {
    static let tailInset: CGFloat = 8

    /// The message direction.
    public var direction: MessageDirection

    /// The position inside a grouped run.
    public var groupPosition: MessageGroupPosition

    /// The outer corner radius.
    public var cornerRadius: CGFloat

    /// The inner grouped corner radius.
    public var groupedInnerCornerRadius: CGFloat

    /// Creates a bubble shape.
    public init(
        direction: MessageDirection,
        groupPosition: MessageGroupPosition,
        cornerRadius: CGFloat = ChatMetrics.messages.bubbleCornerRadius,
        groupedInnerCornerRadius: CGFloat = ChatMetrics.messages.groupedInnerCornerRadius
    ) {
        self.direction = direction
        self.groupPosition = groupPosition
        self.cornerRadius = cornerRadius
        self.groupedInnerCornerRadius = groupedInnerCornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        let tailWidth: CGFloat = showsTail ? Self.tailInset : 0
        let bubbleRect = direction == .incoming
            ? CGRect(x: rect.minX + tailWidth, y: rect.minY, width: rect.width - tailWidth, height: rect.height)
            : CGRect(x: rect.minX, y: rect.minY, width: rect.width - tailWidth, height: rect.height)

        if showsTail {
            return tailedPath(in: bubbleRect)
        }

        return UnevenRoundedRectangle(
            cornerRadii: cornerRadii,
            style: .continuous
        )
        .path(in: bubbleRect)
    }

    private var showsTail: Bool {
        groupPosition == .single || groupPosition == .last
    }

    private var cornerRadii: RectangleCornerRadii {
        switch (direction, groupPosition) {
        case (.incoming, .single):
            return RectangleCornerRadii(
                topLeading: cornerRadius,
                bottomLeading: groupedInnerCornerRadius,
                bottomTrailing: cornerRadius,
                topTrailing: cornerRadius
            )
        case (.outgoing, .single):
            return RectangleCornerRadii(
                topLeading: cornerRadius,
                bottomLeading: cornerRadius,
                bottomTrailing: groupedInnerCornerRadius,
                topTrailing: cornerRadius
            )
        case (.incoming, .last):
            return RectangleCornerRadii(
                topLeading: groupedInnerCornerRadius,
                bottomLeading: groupedInnerCornerRadius,
                bottomTrailing: cornerRadius,
                topTrailing: cornerRadius
            )
        case (.outgoing, .last):
            return RectangleCornerRadii(
                topLeading: cornerRadius,
                bottomLeading: cornerRadius,
                bottomTrailing: groupedInnerCornerRadius,
                topTrailing: groupedInnerCornerRadius
            )
        case (.incoming, .first):
            return RectangleCornerRadii(
                topLeading: cornerRadius,
                bottomLeading: groupedInnerCornerRadius,
                bottomTrailing: cornerRadius,
                topTrailing: cornerRadius
            )
        case (.incoming, .middle):
            return RectangleCornerRadii(
                topLeading: groupedInnerCornerRadius,
                bottomLeading: groupedInnerCornerRadius,
                bottomTrailing: cornerRadius,
                topTrailing: cornerRadius
            )
        case (.outgoing, .first):
            return RectangleCornerRadii(
                topLeading: cornerRadius,
                bottomLeading: cornerRadius,
                bottomTrailing: groupedInnerCornerRadius,
                topTrailing: cornerRadius
            )
        case (.outgoing, .middle):
            return RectangleCornerRadii(
                topLeading: cornerRadius,
                bottomLeading: cornerRadius,
                bottomTrailing: groupedInnerCornerRadius,
                topTrailing: groupedInnerCornerRadius
            )
        }
    }

    private func tailedPath(in rect: CGRect) -> Path {
        let radii = cornerRadii
        let topLeading = clampedRadius(radii.topLeading, in: rect)
        let bottomLeading = clampedRadius(radii.bottomLeading, in: rect)
        let bottomTrailing = clampedRadius(radii.bottomTrailing, in: rect)
        let topTrailing = clampedRadius(radii.topTrailing, in: rect)

        let tailExtent = Self.tailInset
        let tailDrop: CGFloat = 1.75
        let tailJoinHeight = min(9, rect.height * 0.32)
        let tailBodyInset = min(max(5, groupedInnerCornerRadius * 0.7), rect.width * 0.18)
        let tailNotchInset: CGFloat = 0.8
        let tailNotchLift: CGFloat = 1.1

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + topLeading, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topTrailing, y: rect.minY))
        addCorner(
            to: &path,
            corner: .topTrailing,
            radius: topTrailing,
            in: rect
        )

        switch direction {
        case .incoming:
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomTrailing))
            addCorner(
                to: &path,
                corner: .bottomTrailing,
                radius: bottomTrailing,
                in: rect
            )
            path.addLine(to: CGPoint(x: rect.minX + tailBodyInset, y: rect.maxY))
            path.addCurve(
                to: CGPoint(x: rect.minX - tailExtent, y: rect.maxY + tailDrop),
                control1: CGPoint(x: rect.minX + tailBodyInset * 0.4, y: rect.maxY),
                control2: CGPoint(x: rect.minX - tailExtent * 0.7, y: rect.maxY - 0.25)
            )
            path.addCurve(
                to: CGPoint(x: rect.minX + tailNotchInset, y: rect.maxY - tailNotchLift),
                control1: CGPoint(x: rect.minX - tailExtent * 0.78, y: rect.maxY + tailDrop),
                control2: CGPoint(x: rect.minX - 0.6, y: rect.maxY + 0.3)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY - tailJoinHeight),
                control: CGPoint(x: rect.minX, y: rect.maxY - tailJoinHeight * 0.38)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeading))
            addCorner(
                to: &path,
                corner: .topLeading,
                radius: topLeading,
                in: rect
            )
        case .outgoing:
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tailJoinHeight))
            path.addCurve(
                to: CGPoint(x: rect.maxX + tailExtent, y: rect.maxY + tailDrop),
                control1: CGPoint(x: rect.maxX, y: rect.maxY - tailJoinHeight * 0.38),
                control2: CGPoint(x: rect.maxX + tailExtent * 0.7, y: rect.maxY - 0.25)
            )
            path.addCurve(
                to: CGPoint(x: rect.maxX - tailNotchInset, y: rect.maxY - tailNotchLift),
                control1: CGPoint(x: rect.maxX + tailExtent * 0.78, y: rect.maxY + tailDrop),
                control2: CGPoint(x: rect.maxX + 0.6, y: rect.maxY + 0.3)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - tailBodyInset, y: rect.maxY),
                control: CGPoint(x: rect.maxX - tailBodyInset * 0.18, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX + bottomLeading, y: rect.maxY))
            addCorner(
                to: &path,
                corner: .bottomLeading,
                radius: bottomLeading,
                in: rect
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeading))
            addCorner(
                to: &path,
                corner: .topLeading,
                radius: topLeading,
                in: rect
            )
        }

        path.closeSubpath()
        return path
    }

    private func clampedRadius(_ radius: CGFloat, in rect: CGRect) -> CGFloat {
        min(max(radius, 0), min(rect.width / 2, rect.height / 2))
    }

    private func addCorner(
        to path: inout Path,
        corner: BubbleCorner,
        radius: CGFloat,
        in rect: CGRect
    ) {
        guard radius > 0 else {
            switch corner {
            case .topLeading:
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            case .topTrailing:
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            case .bottomTrailing:
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            case .bottomLeading:
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            }
            return
        }

        switch corner {
        case .topLeading:
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + radius, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
        case .topTrailing:
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                control: CGPoint(x: rect.maxX, y: rect.minY)
            )
        case .bottomTrailing:
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
        case .bottomLeading:
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY - radius),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
        }
    }
}

private enum BubbleCorner {
    case topLeading
    case topTrailing
    case bottomTrailing
    case bottomLeading
}
