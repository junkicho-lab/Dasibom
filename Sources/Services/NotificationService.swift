import Foundation
import UserNotifications

/// 로컬 알림 (P1-R3). 권한·스케줄·취소.
/// 🚨 권한 요청은 사람 동의 영역 — 앱 시작 시 1회 요청.
enum NotificationService {

    /// 순수 로직(테스트용): 알림 요청을 만들 수 있으면 반환, 아니면 nil.
    /// notifyAt 없음 / 과거 시각 / 완료 항목 → nil.
    static func makeRequest(for item: Item, now: Date = .now) -> UNNotificationRequest? {
        guard !item.isDone, let notifyAt = item.notifyAt, notifyAt > now else { return nil }
        let content = UNMutableNotificationContent()
        content.title = "다시봄"
        content.body = item.title
        content.sound = .default
        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: notifyAt
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        return UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
    }

    @discardableResult
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// 기존 알림 취소 후, 가능하면 다시 등록.
    static func reschedule(_ item: Item) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        if let request = makeRequest(for: item) { center.add(request) }
    }

    static func cancel(_ item: Item) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }
}
