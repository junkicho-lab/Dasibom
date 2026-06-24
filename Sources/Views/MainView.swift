import SwiftUI
import SwiftData

/// S1 메인 (오늘·예정) — 적어둔 걸 다시 보게 하는 핵심 화면 (P2-S1).
struct MainView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Item.dueAt), SortDescriptor(\Item.createdAt)])
    private var items: [Item]
    @State private var draft = ""

    @AppStorage("notifyByDefault") private var notifyByDefault = true
    @AppStorage("defaultLeadMinutes") private var defaultLeadMinutes = 0

    private var today: [Item] { ItemPartition.today(items) }
    private var upcoming: [Item] { ItemPartition.upcoming(items) }
    private var someday: [Item] { ItemPartition.someday(items) }
    private var isEmpty: Bool { today.isEmpty && upcoming.isEmpty && someday.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                quickInput
                if isEmpty { emptyState } else { listView }
            }
            .navigationTitle("다시봄")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { SettingsView() } label: { Image(systemName: "gearshape") }
                }
            }
        }
        .task {
            seedDemoIfNeeded()
            SnapshotPublisher.publish(context: context)       // 위젯 스냅샷 갱신(권한과 무관)
            await NotificationService.requestAuthorization()  // 🚨 권한 요청(시작 1회)
        }
        .onChange(of: items.count) {
            SnapshotPublisher.publish(context: context)
        }
    }

    // 상단 빠른 입력바 (1초 입력 · 🟦성역)
    private var quickInput: some View {
        HStack(spacing: 8) {
            TextField("할 일을 한 줄로… 예) 내일 3시 치과", text: $draft)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .onSubmit(add)
            Button(action: add) {
                Image(systemName: "plus.circle.fill").font(.title2)
            }
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var listView: some View {
        List {
            section("오늘", today)
            section("예정", upcoming)
            section("언젠가", someday)
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func section(_ title: String, _ rows: [Item]) -> some View {
        if !rows.isEmpty {
            Section(title) {
                ForEach(rows) { item in row(item) }
            }
        }
    }

    private func row(_ item: Item) -> some View {
        HStack(spacing: 12) {
            Button {
                ItemStore(context).complete(item)          // 반복=다음으로 굴림, 단발=완료
                NotificationService.reschedule(item)
                SnapshotPublisher.publish(context: context)
            } label: {
                Image(systemName: "circle").foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)

            NavigationLink {
                ItemEditView(item: item)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(item.title)
                        if item.isRecurring {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    if let due = item.dueAt {
                        Text(due, format: .dateTime.month().day().hour().minute())
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "할 일이 없어요",
            systemImage: "tray",
            description: Text("위에 한 줄로 적어보세요. 예) 내일 3시 치과")
        )
        .frame(maxHeight: .infinity)
    }

    private func add() {
        let parsed = NaturalDateParser.parse(draft)
        guard !parsed.title.isEmpty else { return }
        var notifyAt: Date?
        if notifyByDefault, let due = parsed.dueAt {
            notifyAt = due.addingTimeInterval(TimeInterval(-defaultLeadMinutes * 60))
        }
        let item = Item(title: parsed.title, dueAt: parsed.dueAt, notifyAt: notifyAt)
        context.insert(item)
        NotificationService.reschedule(item)
        SnapshotPublisher.publish(context: context)
        draft = ""
    }

    /// 개발용 — `-seedDemo` 런치 인자가 있고 비어있을 때만 샘플 주입(스크린샷용, 평소 비활성).
    private func seedDemoIfNeeded() {
        guard CommandLine.arguments.contains("-seedDemo"), items.isEmpty else { return }
        let cal = Calendar.current
        let base = cal.startOfDay(for: .now)
        func at(_ dayOffset: Int, _ hour: Int) -> Date {
            cal.date(byAdding: .day, value: dayOffset,
                     to: cal.date(bySettingHour: hour, minute: 0, second: 0, of: base)!)!
        }
        let meeting = Item(title: "팀 회의", dueAt: at(0, 9))
        meeting.recurrence = RecurrenceRule(frequency: .weekdays)   // 평일 반복(아이콘 표시)
        context.insert(meeting)
        context.insert(Item(title: "치과 예약", dueAt: at(0, 15)))
        context.insert(Item(title: "엄마 생신 선물 사기", dueAt: at(3, 11)))
        context.insert(Item(title: "읽고 싶은 책 메모", dueAt: nil))
    }
}

#Preview {
    MainView()
        .modelContainer(for: Item.self, inMemory: true)
}
