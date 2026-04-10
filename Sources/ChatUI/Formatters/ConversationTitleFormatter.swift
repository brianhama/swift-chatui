import Foundation

struct ConversationTitleFormatter {
    func title(for conversation: ChatConversation) -> String {
        if let explicitTitle = conversation.explicitTitle, explicitTitle.isEmpty == false {
            return explicitTitle
        }

        let others = conversation.participants.filter { $0.id != conversation.currentUserID }
        if conversation.kind == .direct {
            return others.first?.displayName ?? "Unknown"
        }

        let visibleNames = others.map(\.displayName)
        switch visibleNames.count {
        case 0:
            return "Unknown Group"
        case 1:
            return visibleNames[0]
        case 2:
            return visibleNames.joined(separator: ", ")
        default:
            let leading = visibleNames.prefix(2).joined(separator: ", ")
            return "\(leading) and \(visibleNames.count - 2) others"
        }
    }

    func title(for preview: ConversationPreview) -> String {
        title(
            for: ChatConversation(
                id: preview.id,
                kind: preview.kind,
                explicitTitle: preview.explicitTitle,
                participants: preview.participants,
                currentUserID: preview.currentUserID
            )
        )
    }
}
