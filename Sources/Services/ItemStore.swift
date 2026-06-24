import Foundation
import SwiftData

/// 로컬 항목 저장·조회 (P1-R1-T2).
/// 화면(S1)의 today / upcoming / someday 쿼리를 제공한다.
/// 작은 개인 데이터셋이라 active 목록을 가져와 Swift에서 파티션(견고·테스트 용이).
struct ItemStore {
    let context: ModelContext
    init(_ context: ModelContext) { self.context = context }

    @discardableResult
    func add(title: String, dueAt: Date? = nil, notifyAt: Date? = nil) -> Item {
        let item = Item(title: title, dueAt: dueAt, notifyAt: notifyAt)
        context.insert(item)
        return item
    }

    /// 완료 토글 — 레코드 삭제가 아님(불변식, 🟦성역).
    func toggleDone(_ item: Item) { item.isDone.toggle() }

    /// 완료 처리: 반복 항목이면 다음 발생으로 굴리고(미완료 유지), 단발이면 isDone=true.
    /// (알림 재등록·스냅샷 갱신은 호출자가 수행 — Store는 데이터만.)
    func complete(_ item: Item, now: Date = .now, calendar: Calendar = .current) {
        if let rule = item.recurrence,
           let due = item.dueAt,
           let next = RecurrenceEngine.next(after: due, rule: rule, calendar: calendar) {
            let notifyDelta = item.notifyAt.map { $0.timeIntervalSince(due) }
            item.dueAt = next
            if let notifyDelta { item.notifyAt = next.addingTimeInterval(notifyDelta) }
        } else {
            item.isDone = true
        }
    }

    func delete(_ item: Item) { context.delete(item) }

    /// 미완료 항목, dueAt → createdAt 순.
    func allActive() -> [Item] {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { $0.isDone == false },
            sortBy: [SortDescriptor(\.dueAt), SortDescriptor(\.createdAt)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 오늘(또는 지난 미완료) — 파티션 로직은 ItemPartition 공유(UI와 동일 기준).
    func today(now: Date = .now, calendar: Calendar = .current) -> [Item] {
        ItemPartition.today(allActive(), now: now, calendar: calendar)
    }

    /// 예정.
    func upcoming(now: Date = .now, calendar: Calendar = .current) -> [Item] {
        ItemPartition.upcoming(allActive(), now: now, calendar: calendar)
    }

    /// 언젠가: 날짜 없는 미완료.
    func someday() -> [Item] { ItemPartition.someday(allActive()) }
}
