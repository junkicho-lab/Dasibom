import Foundation

/// 반복 규칙에서 다음 발생 시각을 계산하는 순수 로직 (시:분 유지).
enum RecurrenceEngine {

    static func next(after date: Date, rule: RecurrenceRule, calendar: Calendar = .current) -> Date? {
        switch rule.frequency {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)

        case .weekdays:
            var d = date
            repeat {
                d = calendar.date(byAdding: .day, value: 1, to: d)!
            } while isWeekend(d, calendar)
            return d

        case .weekly:
            let targets = rule.weekdays.isEmpty
                ? [calendar.component(.weekday, from: date)]   // 요일 미지정 → 같은 요일
                : rule.weekdays
            var d = date
            for _ in 1...7 {
                d = calendar.date(byAdding: .day, value: 1, to: d)!
                if targets.contains(calendar.component(.weekday, from: d)) { return d }
            }
            return d

        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)  // 말일 자동 보정
        }
    }

    private static func isWeekend(_ date: Date, _ calendar: Calendar) -> Bool {
        let wd = calendar.component(.weekday, from: date)
        return wd == 1 || wd == 7   // 일(1) · 토(7)
    }
}
