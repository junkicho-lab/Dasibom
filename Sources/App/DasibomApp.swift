import SwiftUI
import SwiftData

@main
struct DasibomApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        // P0-T0.2: SwiftData 로컬 컨테이너 (외부 전송 없음 · 🟦성역)
        .modelContainer(for: Item.self)
    }
}
