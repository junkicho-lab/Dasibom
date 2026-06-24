import XCTest
import SwiftData
@testable import Dasibom

/// Could — 반복 엔진 + complete() 굴림 동작.
final class RecurrenceTests: XCTestCase {
    private let cal = Calendar(identifier: .gregorian)

    /// 2026-06-23 화요일 15:00
    private func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 15, _ min: Int = 0) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: min))!
    }

    func testDailyKeepsTime() {
        let r = RecurrenceEngine.next(after: date(2026, 6, 23, 15, 30),
                                      rule: .init(frequency: .daily), calendar: cal)
        let c = cal.dateComponents([.month, .day, .hour, .minute], from: r!)
        XCTAssertEqual(c.day, 24); XCTAssertEqual(c.hour, 15); XCTAssertEqual(c.minute, 30)
    }

    func testWeekdaysSkipsWeekend() {
        // 금요일(6/26) → 다음 평일은 월요일(6/29)
        let r = RecurrenceEngine.next(after: date(2026, 6, 26),
                                      rule: .init(frequency: .weekdays), calendar: cal)
        XCTAssertEqual(cal.component(.day, from: r!), 29)
    }

    func testWeeklySpecificDays() {
        // 화(6/23) 기준 매주 월(2)·수(4) → 다음은 수(6/24)
        let r = RecurrenceEngine.next(after: date(2026, 6, 23),
                                      rule: .init(frequency: .weekly, weekdays: [2, 4]), calendar: cal)
        XCTAssertEqual(cal.component(.day, from: r!), 24)
    }

    func testMonthlyClampsMonthEnd() {
        // 1/31 매월 → 2월은 28일로 보정
        let r = RecurrenceEngine.next(after: date(2026, 1, 31),
                                      rule: .init(frequency: .monthly), calendar: cal)
        let c = cal.dateComponents([.month, .day], from: r!)
        XCTAssertEqual(c.month, 2); XCTAssertEqual(c.day, 28)
    }

    func testCompleteRecurringRollsForward() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let ctx = ModelContext(container)
        let store = ItemStore(ctx)
        let item = store.add(title: "약 먹기", dueAt: date(2026, 6, 23))
        item.recurrence = RecurrenceRule(frequency: .daily)

        store.complete(item)

        XCTAssertFalse(item.isDone, "반복은 완료 대신 다음으로 굴림")
        XCTAssertEqual(cal.component(.day, from: item.dueAt!), 24)
    }

    func testCompleteNonRecurringMarksDone() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let ctx = ModelContext(container)
        let store = ItemStore(ctx)
        let item = store.add(title: "치과", dueAt: date(2026, 6, 23))

        store.complete(item)

        XCTAssertTrue(item.isDone)
    }
}
