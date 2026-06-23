import XCTest
@testable import Dasibom

/// P1-R2 — 자연어 날짜 파서. 고정 now로 결정적 테스트.
final class NaturalDateParserTests: XCTestCase {

    private var cal = Calendar(identifier: .gregorian)
    /// 2026-06-23(화) 10:00 기준
    private lazy var now: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 6; c.day = 23; c.hour = 10; c.minute = 0
        return cal.date(from: c)!
    }()

    private func comps(_ d: Date?) -> DateComponents? {
        guard let d else { return nil }
        return cal.dateComponents([.year, .month, .day, .hour, .minute], from: d)
    }

    func testTomorrowAfternoon() {
        let r = NaturalDateParser.parse("내일 3시 치과", now: now, calendar: cal)
        XCTAssertEqual(r.title, "치과")
        let c = comps(r.dueAt)
        XCTAssertEqual(c?.day, 24)
        XCTAssertEqual(c?.hour, 15)   // 3시 → 오후 15:00 (통념)
        XCTAssertEqual(c?.minute, 0)
    }

    func testTodayMorningExplicit() {
        let r = NaturalDateParser.parse("오늘 9시 회의", now: now, calendar: cal)
        XCTAssertEqual(r.title, "회의")
        XCTAssertEqual(comps(r.dueAt)?.hour, 9)   // 9시는 오전 그대로
        XCTAssertEqual(comps(r.dueAt)?.day, 23)
    }

    func testHalfPastWithMeridiem() {
        let r = NaturalDateParser.parse("오후 3시 30분 미팅", now: now, calendar: cal)
        XCTAssertEqual(r.title, "미팅")
        XCTAssertEqual(comps(r.dueAt)?.hour, 15)
        XCTAssertEqual(comps(r.dueAt)?.minute, 30)
    }

    func testDayOnlyDefaultsToNine() {
        let r = NaturalDateParser.parse("모레 치과", now: now, calendar: cal)
        XCTAssertEqual(r.title, "치과")
        XCTAssertEqual(comps(r.dueAt)?.day, 25)
        XCTAssertEqual(comps(r.dueAt)?.hour, 9)    // 시간 없으면 09:00 기본
    }

    func testNoDateGraceful() {
        let r = NaturalDateParser.parse("우유 사기", now: now, calendar: cal)
        XCTAssertEqual(r.title, "우유 사기")
        XCTAssertNil(r.dueAt, "날짜 토큰 없으면 dueAt nil, 입력은 그대로")
    }

    func testEmpty() {
        let r = NaturalDateParser.parse("   ", now: now, calendar: cal)
        XCTAssertEqual(r.title, "")
        XCTAssertNil(r.dueAt)
    }
}
