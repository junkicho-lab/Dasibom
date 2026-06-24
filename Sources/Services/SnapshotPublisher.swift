import Foundation
import SwiftData
import WidgetKit

/// 앱 데이터 변경 시 위젯용 스냅샷을 갱신하고 타임라인을 새로고침.
enum SnapshotPublisher {
    static func publish(context: ModelContext, now: Date = .now) {
        let active = ItemStore(context).allActive()
        let today = ItemPartition.today(active, now: now)
        let upcomingSoon = ItemPartition.upcoming(active, now: now).prefix(3)
        let visible = today + upcomingSoon

        let snapshot = TodaySnapshot(
            generatedAt: now,
            items: visible.map {
                SnapshotItem(id: $0.id.uuidString, title: $0.title,
                             dueAt: $0.dueAt, isRecurring: $0.isRecurring)
            },
            remainingCount: today.count
        )
        SharedStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
