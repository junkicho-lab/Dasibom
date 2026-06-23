import XCTest
import SwiftData
@testable import Dasibom

/// P1-R1 / R1-T2 — Item 불변식 + ItemStore 쿼리.
final class ItemStoreTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        return ModelContext(container)
    }

    func testItemDefaults() {
        let item = Item(title: "치과")
        XCTAssertEqual(item.title, "치과")
        XCTAssertFalse(item.isDone)
        XCTAssertNil(item.dueAt)
        XCTAssertNil(item.notifyAt)
    }

    func testCompletionTogglesNotDeletes() throws {
        let ctx = try makeContext()
        let store = ItemStore(ctx)
        let item = store.add(title: "치과")

        store.toggleDone(item)

        XCTAssertTrue(item.isDone)
        XCTAssertEqual(store.allActive().count, 0, "완료 항목은 active에서 제외")
        let all = try ctx.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(all.count, 1, "완료는 토글일 뿐 레코드는 남는다(불변식)")
    }

    func testPartitionsTodayUpcomingSomeday() throws {
        let ctx = try makeContext()
        let store = ItemStore(ctx)
        let cal = Calendar.current
        let now = Date()

        store.add(title: "지금 일", dueAt: now)                                   // today
        store.add(title: "모레 일", dueAt: cal.date(byAdding: .day, value: 2, to: now)) // upcoming
        store.add(title: "언젠가 일")                                              // someday

        XCTAssertEqual(store.today(now: now).count, 1)
        XCTAssertEqual(store.upcoming(now: now).count, 1)
        XCTAssertEqual(store.someday().count, 1)
    }

    func testPastDueCountsAsToday() throws {
        let ctx = try makeContext()
        let store = ItemStore(ctx)
        let now = Date()
        store.add(title: "어제 놓친 일", dueAt: now.addingTimeInterval(-86_400)) // 지난 미완료
        XCTAssertEqual(store.today(now: now).count, 1, "지난 미완료도 오늘 묶음")
    }
}
