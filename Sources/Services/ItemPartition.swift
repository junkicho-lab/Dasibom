import Foundation

/// 항목 목록을 오늘/예정/언젠가로 가르는 순수 함수 (Store와 UI가 공유).
enum ItemPartition {
    private static func tomorrowStart(_ now: Date, _ cal: Calendar) -> Date {
        cal.startOfDay(for: now).addingTimeInterval(86_400)
    }

    /// 오늘(또는 지난 미완료): dueAt < 내일 00:00.
    static func today(_ items: [Item], now: Date = .now, calendar: Calendar = .current) -> [Item] {
        let t = tomorrowStart(now, calendar)
        return items.filter { !$0.isDone && ($0.dueAt.map { $0 < t } ?? false) }
    }

    /// 예정: dueAt >= 내일 00:00.
    static func upcoming(_ items: [Item], now: Date = .now, calendar: Calendar = .current) -> [Item] {
        let t = tomorrowStart(now, calendar)
        return items.filter { !$0.isDone && ($0.dueAt.map { $0 >= t } ?? false) }
    }

    /// 언젠가: 날짜 없는 미완료.
    static func someday(_ items: [Item]) -> [Item] {
        items.filter { !$0.isDone && $0.dueAt == nil }
    }
}
