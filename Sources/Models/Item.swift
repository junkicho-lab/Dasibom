import Foundation
import SwiftData

/// 할 일/일정 항목 (로컬 SwiftData 모델).
/// 불변식: 완료는 `isDone` 토글로 처리(레코드 삭제 아님), 날짜는 옵셔널('언젠가' 허용).
/// 상세 동작·테스트는 P1-R1에서 보강.
@Model
final class Item {
    var id: UUID
    var title: String
    var dueAt: Date?
    var notifyAt: Date?
    var isDone: Bool
    var createdAt: Date
    /// 반복 규칙(Could). nil = 단발. SwiftData에 Codable로 저장(추가 옵셔널 → 라이트웨이트 마이그레이션).
    var recurrence: RecurrenceRule?

    init(
        title: String,
        dueAt: Date? = nil,
        notifyAt: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = .now,
        recurrence: RecurrenceRule? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.dueAt = dueAt
        self.notifyAt = notifyAt
        self.isDone = isDone
        self.createdAt = createdAt
        self.recurrence = recurrence
    }

    var isRecurring: Bool { recurrence != nil }
}
