import SwiftUI

/// A compact composite avatar for group conversations.
public struct GroupAvatarView: View {
    /// The participants shown in the avatar.
    public var participants: [ChatParticipant]

    /// The rendered avatar size.
    public var size: CGFloat

    /// Creates a group avatar view.
    public init(participants: [ChatParticipant], size: CGFloat = ChatMetrics.messages.groupConversationAvatarSize) {
        self.participants = participants
        self.size = size
    }

    public var body: some View {
        ZStack {
            switch visibleParticipants.count {
            case 0:
                Circle()
                    .fill(Color.secondary.opacity(0.18))
                    .overlay(Image(systemName: "person.2.fill").foregroundStyle(.secondary))
            case 1:
                AvatarView(participant: visibleParticipants[0], size: size)
            case 2:
                twoUpAvatar
            default:
                gridAvatar
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityLabel))
    }

    private var visibleParticipants: [ChatParticipant] {
        Array(participants.prefix(4))
    }

    private var accessibilityLabel: String {
        let names = participants.prefix(4).map(\.displayName).joined(separator: ", ")
        return names.isEmpty ? "Group conversation" : "Group conversation with \(names)"
    }

    private var twoUpAvatar: some View {
        ZStack {
            AvatarView(participant: visibleParticipants[1], size: size * 0.68)
                .offset(x: size * 0.16, y: size * 0.16)
            AvatarView(participant: visibleParticipants[0], size: size * 0.68)
                .offset(x: -size * 0.16, y: -size * 0.16)
        }
    }

    private var gridAvatar: some View {
        VStack(spacing: size * 0.04) {
            HStack(spacing: size * 0.04) {
                AvatarView(participant: visibleParticipants[0], size: size * 0.46)
                AvatarView(participant: visibleParticipants[1], size: size * 0.46)
            }
            HStack(spacing: size * 0.04) {
                AvatarView(participant: visibleParticipants[2], size: size * 0.46)
                if let fourth = visibleParticipants[safe: 3] {
                    AvatarView(participant: fourth, size: size * 0.46)
                } else {
                    Circle()
                        .fill(Color.secondary.opacity(0.16))
                        .frame(width: size * 0.46, height: size * 0.46)
                }
            }
        }
    }
}

#Preview("Group Avatar") {
    GroupAvatarView(
        participants: [
            ChatParticipant(id: "1", displayName: "Alex", initials: "AL", accentColorToken: "1"),
            ChatParticipant(id: "2", displayName: "Sam", initials: "SA", accentColorToken: "2"),
            ChatParticipant(id: "3", displayName: "Taylor", initials: "TA", accentColorToken: "3"),
            ChatParticipant(id: "4", displayName: "Jordan", initials: "JO", accentColorToken: "4")
        ],
        size: 60
    )
    .padding()
}
