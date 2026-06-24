import SwiftUI
import SwiftData

/// S2 추가/편집 (P2-S2). 로컬 상태로 편집 → 저장 시 반영(빈 제목 차단).
struct ItemEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let item: Item

    @State private var title: String
    @State private var hasDue: Bool
    @State private var due: Date
    @State private var hasNotify: Bool
    @State private var notify: Date
    @State private var recurrence: RecurrenceFrequency?   // nil = 반복 없음
    @State private var weekdays: Set<Int>

    init(item: Item) {
        self.item = item
        _title = State(initialValue: item.title)
        _hasDue = State(initialValue: item.dueAt != nil)
        _due = State(initialValue: item.dueAt ?? .now)
        _hasNotify = State(initialValue: item.notifyAt != nil)
        _notify = State(initialValue: item.notifyAt ?? item.dueAt ?? .now)
        _recurrence = State(initialValue: item.recurrence?.frequency)
        _weekdays = State(initialValue: Set(item.recurrence?.weekdays ?? []))
    }

    private let weekdayNames = ["일", "월", "화", "수", "목", "금", "토"]

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            Section("할 일") {
                TextField("내용", text: $title)
            }
            Section("일정") {
                Toggle("날짜·시간", isOn: $hasDue.animation())
                if hasDue {
                    DatePicker("언제", selection: $due)
                }
            }
            Section("알림") {
                Toggle("알림", isOn: $hasNotify.animation())
                if hasNotify {
                    DatePicker("알릴 시각", selection: $notify)
                }
            }
            Section("반복") {
                Picker("반복", selection: $recurrence.animation()) {
                    Text("없음").tag(RecurrenceFrequency?.none)
                    ForEach(RecurrenceFrequency.allCases) { freq in
                        Text(freq.label).tag(RecurrenceFrequency?.some(freq))
                    }
                }
                if recurrence == .weekly {
                    HStack {
                        ForEach(1...7, id: \.self) { wd in
                            Button(weekdayNames[wd - 1]) {
                                if weekdays.contains(wd) { weekdays.remove(wd) } else { weekdays.insert(wd) }
                            }
                            .buttonStyle(.borderless)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(weekdays.contains(wd) ? Color.accentColor.opacity(0.2) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                if recurrence != nil && !hasDue {
                    Text("반복은 날짜가 있어야 동작해요.").font(.caption).foregroundStyle(.orange)
                }
            }
            Section {
                Button("삭제", role: .destructive) {
                    NotificationService.cancel(item)
                    context.delete(item)
                    SnapshotPublisher.publish(context: context)
                    dismiss()
                }
            }
        }
        .navigationTitle("편집")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") { save() }.disabled(!canSave)
            }
        }
    }

    private func save() {
        item.title = title.trimmingCharacters(in: .whitespaces)
        item.dueAt = hasDue ? due : nil
        item.notifyAt = hasNotify ? notify : nil
        if let freq = recurrence {
            item.recurrence = RecurrenceRule(frequency: freq,
                                             weekdays: freq == .weekly ? weekdays.sorted() : [])
        } else {
            item.recurrence = nil
        }
        NotificationService.reschedule(item)
        SnapshotPublisher.publish(context: context)
        dismiss()
    }
}
