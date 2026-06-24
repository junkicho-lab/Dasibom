import WidgetKit
import SwiftUI

struct TodayEntry: TimelineEntry {
    let date: Date
    let snapshot: TodaySnapshot?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, snapshot: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(TodayEntry(date: .now, snapshot: SharedStore.load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let entry = TodayEntry(date: .now, snapshot: SharedStore.load())
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct DasibomWidgetEntryView: View {
    var entry: TodayEntry

    private var items: [SnapshotItem] { entry.snapshot?.items ?? [] }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("오늘 할 일").font(.headline)
                Spacer()
                if let count = entry.snapshot?.remainingCount, count > 0 {
                    Text("\(count)").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            if items.isEmpty {
                Spacer()
                Text("할 일이 없어요 🎉").font(.caption).foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(items.prefix(4)) { item in
                    HStack(spacing: 6) {
                        Image(systemName: "circle").font(.caption2).foregroundStyle(.secondary)
                        Text(item.title).font(.caption).lineLimit(1)
                        if item.isRecurring {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let due = item.dueAt {
                            Text(due, format: .dateTime.hour().minute())
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct DasibomWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DasibomWidget", provider: Provider()) { entry in
            DasibomWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 할 일")
        .description("다시봄 — 오늘 할 일을 한눈에")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct DasibomWidgetBundle: WidgetBundle {
    var body: some Widget { DasibomWidget() }
}
