import Foundation

struct RelativeDateLabelFormatter {
    var calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func timestampLabel(for date: Date, now: Date = Date()) -> String {
        if calendar.isDate(date, inSameDayAs: now) {
            return date.formatted(.dateTime.hour().minute())
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }

        if let oneWeekAgo = calendar.date(byAdding: .day, value: -6, to: now),
           date >= oneWeekAgo {
            return date.formatted(.dateTime.weekday(.abbreviated))
        }

        return date.formatted(.dateTime.month(.abbreviated).day())
    }

    func separatorLabel(for date: Date, now: Date = Date()) -> String {
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today"
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }

        if let oneWeekAgo = calendar.date(byAdding: .day, value: -6, to: now),
           date >= oneWeekAgo {
            return date.formatted(.dateTime.weekday(.wide))
        }

        return date.formatted(.dateTime.month(.abbreviated).day().year())
    }
}
