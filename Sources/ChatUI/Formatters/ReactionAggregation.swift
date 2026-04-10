import Foundation

struct ReactionAggregate: Hashable, Sendable {
    let emoji: String
    let count: Int
}

struct ReactionAggregator {
    func aggregate(_ reactions: [MessageReaction]) -> [ReactionAggregate] {
        let grouped = Dictionary(grouping: reactions, by: \.emoji)
        return grouped
            .map { ReactionAggregate(emoji: $0.key, count: $0.value.count) }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.emoji < rhs.emoji
                }
                return lhs.count > rhs.count
            }
    }
}
