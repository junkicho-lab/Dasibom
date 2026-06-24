import Foundation

/// 앱 ↔ 위젯 공유 스냅샷 (App Group). 위젯에 SwiftData를 직접 물리지 않고 가벼운 JSON으로 전달.
struct SnapshotItem: Codable, Identifiable {
    var id: String
    var title: String
    var dueAt: Date?
    var isRecurring: Bool
}

struct TodaySnapshot: Codable {
    var generatedAt: Date
    var items: [SnapshotItem]     // 오늘(또는 지난 미완료) + 임박, 정렬됨
    var remainingCount: Int       // 오늘 남은 개수
}

/// App Group 컨테이너에 스냅샷 JSON 읽기/쓰기.
enum SharedStore {
    static let appGroup = "group.com.junkicho.dasibom"
    static let fileName = "today-snapshot.json"

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent(fileName)
    }

    private static var encoder: JSONEncoder {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }
    private static var decoder: JSONDecoder {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }

    static func save(_ snapshot: TodaySnapshot) {
        guard let fileURL, let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func load() -> TodaySnapshot? {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? decoder.decode(TodaySnapshot.self, from: data)
    }
}
