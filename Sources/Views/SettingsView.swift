import SwiftUI
import UserNotifications

/// S3 설정 (P2-S3). 알림 기본값(UserDefaults) + 권한 안내.
struct SettingsView: View {
    @AppStorage("notifyByDefault") private var notifyByDefault = true
    @AppStorage("defaultLeadMinutes") private var defaultLeadMinutes = 0
    @State private var authText = "확인 중…"

    var body: some View {
        Form {
            Section("알림") {
                Toggle("마감 시각에 자동 알림", isOn: $notifyByDefault)
                Picker("기본 알림 시점", selection: $defaultLeadMinutes) {
                    Text("정시").tag(0)
                    Text("10분 전").tag(10)
                    Text("1시간 전").tag(60)
                }
            }
            Section("알림 권한") {
                Text(authText).foregroundStyle(.secondary)
                Button("iOS 설정 열기") { openSettings() }
            }
            Section {
                Text("반복 일정·태그·외부 캘린더 연동은 이번 버전에 없어요.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task { await refreshAuth() }
    }

    private func refreshAuth() async {
        let s = await UNUserNotificationCenter.current().notificationSettings()
        switch s.authorizationStatus {
        case .authorized, .provisional, .ephemeral: authText = "알림 허용됨 ✅"
        case .denied: authText = "알림이 꺼져 있어요. 설정에서 켜야 제때 알림이 가요."
        default: authText = "아직 알림 권한을 묻지 않았어요."
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
