import CoreGraphics
import Foundation

struct TranscriptMessageItem: Identifiable, Hashable {
    let message: ChatMessage
    let context: MessageRowContext
    let topSpacing: CGFloat

    var id: ChatMessage.ID { message.id }
}

struct TranscriptDateSeparatorItem: Identifiable, Hashable {
    let id: String
    let date: Date
}

enum TranscriptDisplayItem: Identifiable, Hashable {
    case dateSeparator(TranscriptDateSeparatorItem)
    case message(TranscriptMessageItem)

    var id: String {
        switch self {
        case let .dateSeparator(separator):
            return separator.id
        case let .message(message):
            return message.id
        }
    }
}

struct MessageStatusDisplayRule {
    func shouldShowStatus(
        for message: ChatMessage,
        in orderedMessages: [ChatMessage],
        currentUserID: ChatParticipant.ID
    ) -> Bool {
        guard message.senderID == currentUserID else {
            return false
        }

        if case .failed = message.status {
            return true
        }

        guard let lastOutgoingMessage = orderedMessages.last(where: { $0.senderID == currentUserID }) else {
            return false
        }

        switch message.status {
        case .sending, .sent, .delivered, .read:
            return message.id == lastOutgoingMessage.id
        case .failed:
            return true
        }
    }
}

struct TranscriptLayoutEngine {
    var calendar: Calendar = .current
    var statusDisplayRule = MessageStatusDisplayRule()

    func makeItems(
        conversation: ChatConversation,
        messages: [ChatMessage],
        configuration: ChatThreadConfiguration
    ) -> [TranscriptDisplayItem] {
        let orderedMessages = stableSort(messages)
        guard orderedMessages.isEmpty == false else {
            return []
        }

        var items: [TranscriptDisplayItem] = []

        for index in orderedMessages.indices {
            let message = orderedMessages[index]
            let previousMessage = index == orderedMessages.startIndex ? nil : orderedMessages[orderedMessages.index(before: index)]
            let nextIndex = orderedMessages.index(after: index)
            let nextMessage = nextIndex == orderedMessages.endIndex ? nil : orderedMessages[nextIndex]

            if shouldInsertSeparator(
                before: message,
                previous: previousMessage,
                strategy: configuration.dateSeparatorStrategy
            ) {
                items.append(
                    .dateSeparator(
                        TranscriptDateSeparatorItem(
                            id: "separator-\(message.id)",
                            date: message.timestamp
                        )
                    )
                )
            }

            let direction = direction(for: message, currentUserID: conversation.currentUserID)
            let previousInRun = previousMessage.map {
                areInSameRun(
                    lhs: $0,
                    rhs: message,
                    currentUserID: conversation.currentUserID,
                    threshold: configuration.groupingThreshold
                )
            } ?? false
            let nextInRun = nextMessage.map {
                areInSameRun(
                    lhs: message,
                    rhs: $0,
                    currentUserID: conversation.currentUserID,
                    threshold: configuration.groupingThreshold
                )
            } ?? false

            let groupPosition = groupPosition(previousInRun: previousInRun, nextInRun: nextInRun)
            let showsSenderName = showsSenderName(
                for: message,
                previous: previousMessage,
                in: conversation,
                previousInRun: previousInRun
            )
            let showsAvatar = showsAvatar(
                for: message,
                in: conversation,
                groupPosition: groupPosition,
                configuration: configuration
            )
            let showsStatus = statusDisplayRule.shouldShowStatus(
                for: message,
                in: orderedMessages,
                currentUserID: conversation.currentUserID
            )
            let topSpacing = previousInRun ? ChatMetrics.messages.messageRunSpacing : ChatMetrics.messages.messageGroupSpacing

            items.append(
                .message(
                    TranscriptMessageItem(
                        message: message,
                        context: MessageRowContext(
                            direction: direction,
                            groupPosition: groupPosition,
                            showsAvatar: showsAvatar,
                            showsSenderName: showsSenderName,
                            showsStatus: showsStatus,
                            isGroupConversation: conversation.kind == .group
                        ),
                        topSpacing: previousMessage == nil ? 0 : topSpacing
                    )
                )
            )
        }

        return items
    }

    func stableSort(_ messages: [ChatMessage]) -> [ChatMessage] {
        messages
            .enumerated()
            .sorted { lhs, rhs in
                if lhs.element.timestamp == rhs.element.timestamp {
                    return lhs.offset < rhs.offset
                }
                return lhs.element.timestamp < rhs.element.timestamp
            }
            .map(\.element)
    }

    func shouldInsertSeparator(
        before message: ChatMessage,
        previous: ChatMessage?,
        strategy: DateSeparatorStrategy
    ) -> Bool {
        guard let previous else {
            return true
        }

        if calendar.isDate(message.timestamp, inSameDayAs: previous.timestamp) == false {
            return true
        }

        switch strategy {
        case .dayChange:
            return false
        case let .dayChangeAndLargeGap(threshold):
            return abs(message.timestamp.timeIntervalSince(previous.timestamp)) > threshold
        }
    }

    func areInSameRun(
        lhs: ChatMessage,
        rhs: ChatMessage,
        currentUserID: ChatParticipant.ID,
        threshold: TimeInterval
    ) -> Bool {
        let lhsDirection = direction(for: lhs, currentUserID: currentUserID)
        let rhsDirection = direction(for: rhs, currentUserID: currentUserID)

        return lhs.senderID == rhs.senderID &&
            lhsDirection == rhsDirection &&
            calendar.isDate(lhs.timestamp, inSameDayAs: rhs.timestamp) &&
            rhs.timestamp.timeIntervalSince(lhs.timestamp) <= threshold
    }

    func direction(for message: ChatMessage, currentUserID: ChatParticipant.ID) -> MessageDirection {
        message.senderID == currentUserID ? .outgoing : .incoming
    }

    func groupPosition(previousInRun: Bool, nextInRun: Bool) -> MessageGroupPosition {
        switch (previousInRun, nextInRun) {
        case (false, false):
            return .single
        case (false, true):
            return .first
        case (true, true):
            return .middle
        case (true, false):
            return .last
        }
    }

    func showsAvatar(
        for message: ChatMessage,
        in conversation: ChatConversation,
        groupPosition: MessageGroupPosition,
        configuration: ChatThreadConfiguration
    ) -> Bool {
        let direction = direction(for: message, currentUserID: conversation.currentUserID)
        guard direction == .incoming else {
            return false
        }

        guard conversation.kind == .group else {
            return configuration.showsDirectChatAvatars
        }

        return groupPosition == .single || groupPosition == .last
    }

    func showsSenderName(
        for message: ChatMessage,
        previous: ChatMessage?,
        in conversation: ChatConversation,
        previousInRun: Bool
    ) -> Bool {
        guard conversation.kind == .group else {
            return false
        }

        guard direction(for: message, currentUserID: conversation.currentUserID) == .incoming else {
            return false
        }

        guard previousInRun == false else {
            return false
        }
        return true
    }
}
