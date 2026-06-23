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

    init(item: Item) {
        self.item = item
        _title = State(initialValue: item.title)
        _hasDue = State(initialValue: item.dueAt != nil)
        _due = State(initialValue: item.dueAt ?? .now)
        _hasNotify = State(initialValue: item.notifyAt != nil)
        _notify = State(initialValue: item.notifyAt ?? item.dueAt ?? .now)
    }

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
            Section {
                Button("삭제", role: .destructive) {
                    NotificationService.cancel(item)
                    context.delete(item)
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
        NotificationService.reschedule(item)
        dismiss()
    }
}
