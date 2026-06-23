import XCTest
import UserNotifications
@testable import Dasibom

/// P1-R3 — 알림 요청 생성 로직(순수). 권한 불필요.
final class NotificationServiceTests: XCTestCase {
    private let now = Date()

    func testNilWhenNoNotifyDate() {
        let item = Item(title: "치과")  // notifyAt 없음
        XCTAssertNil(NotificationService.makeRequest(for: item, now: now))
    }

    func testNilWhenPast() {
        let item = Item(title: "지난 일", notifyAt: now.addingTimeInterval(-60))
        XCTAssertNil(NotificationService.makeRequest(for: item, now: now))
    }

    func testNilWhenDone() {
        let item = Item(title: "끝난 일", notifyAt: now.addingTimeInterval(3600), isDone: true)
        XCTAssertNil(NotificationService.makeRequest(for: item, now: now))
    }

    func testRequestWhenFuture() {
        let item = Item(title: "회의", notifyAt: now.addingTimeInterval(3600))
        let req = NotificationService.makeRequest(for: item, now: now)
        XCTAssertNotNil(req)
        XCTAssertEqual(req?.identifier, item.id.uuidString)
        XCTAssertEqual(req?.content.body, "회의")
        XCTAssertTrue(req?.trigger is UNCalendarNotificationTrigger)
    }
}
