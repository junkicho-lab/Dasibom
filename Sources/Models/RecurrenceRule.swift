import Foundation

/// 반복 빈도 (Could 기능). weekday: 1=일 … 7=토 (Calendar 기준).
enum RecurrenceFrequency: String, Codable, CaseIterable, Identifiable {
    case daily      // 매일
    case weekdays   // 평일(월~금)
    case weekly     // 매주(지정 요일)
    case monthly    // 매월(같은 날)

    var id: String { rawValue }
    var label: String {
        switch self {
        case .daily: "매일"
        case .weekdays: "평일(월~금)"
        case .weekly: "매주"
        case .monthly: "매월"
        }
    }
}

/// 반복 규칙. weekly일 때만 weekdays 사용.
struct RecurrenceRule: Codable, Equatable {
    var frequency: RecurrenceFrequency
    var weekdays: [Int] = []   // weekly 전용 (1=일 … 7=토)

    var shortLabel: String {
        switch frequency {
        case .weekly where !weekdays.isEmpty:
            let names = ["일","월","화","수","목","금","토"]
            return "매주 " + weekdays.sorted().map { names[($0 - 1) % 7] }.joined(separator: "·")
        default:
            return frequency.label
        }
    }
}
