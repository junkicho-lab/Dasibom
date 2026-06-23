# 아키텍처 (Architecture)
> 다시봄 기획 — 아키텍처 설계

## 1. 설계 원칙

- **로컬 우선 (성역)**: 모든 데이터는 기기 내 SwiftData에만 저장. 외부 전송 없음.
- **단순함 우선**: 백엔드·네트워크 계층 없음. 단일 사용자 개인용에 맞춘 최소 구조.
- **SwiftUI 선언형 + 경량 MVVM**: 화면 3개 규모에 맞게 과한 추상화 지양.

## 2. 아키텍처 패턴: 경량 MVVM

화면이 3개로 작으므로 본격 MVVM보다 **View + @Observable ViewModel + SwiftData @Model** 의 경량 구성을 채택한다.

| 레이어 | 구성 요소 | 책임 |
|--------|----------|------|
| View | SwiftUI View | 화면 렌더링, 사용자 입력 수집, ViewModel 바인딩 |
| ViewModel | `@Observable` 클래스 | 화면 상태, 입력 파싱 트리거, 정렬/필터, 저장 호출 |
| Model | SwiftData `@Model` (Task) | 영속 데이터 정의 |
| Service | NaturalLanguageParser, NotificationScheduler | 자연어 파싱, 로컬 알림 예약/취소 |
| Store | `ModelContext` (SwiftData) | CRUD, 영속성 |

> 단순 화면(예: 설정)은 ViewModel 없이 View + `@Query`/`@AppStorage`로 직접 처리 가능.

## 3. 레이어별 책임

### View
- 메인: 입력바 + 오늘/예정 리스트, 체크 토글 액션 전달.
- 추가/편집: 제목·날짜·알림 시각 편집 폼.
- 설정: 기본 알림 시간 등 환경설정.

### ViewModel
- 입력 문자열을 `NaturalLanguageParser`에 전달해 `dueAt`/`notifyAt` 도출.
- 항목을 오늘/예정/날짜없음으로 분류·정렬.
- 저장/완료/삭제 시 `ModelContext`와 `NotificationScheduler` 호출 조율.

### Service
- **NaturalLanguageParser**: "내일 3시 치과" → (title, dueAt, notifyAt) 변환. (`NSDataDetector`/`Date` 파싱 활용)
- **NotificationScheduler**: `UNUserNotificationCenter` 래퍼. 권한 요청, 예약(`UNCalendarNotificationTrigger`), 취소(identifier = Task.id).

### Store (SwiftData)
- `ModelContext`로 Task CRUD. 메인은 `@Query`로 자동 갱신.

## 4. 데이터 모델

```swift
@Model
final class Task {
    var id: UUID
    var title: String
    var dueAt: Date?       // 마감/예정 시각 (없으면 날짜 미정)
    var isDone: Bool
    var createdAt: Date
    var notifyAt: Date?    // 로컬 알림 예약 시각

    init(title: String, dueAt: Date? = nil, notifyAt: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.dueAt = dueAt
        self.isDone = false
        self.createdAt = Date()
        self.notifyAt = notifyAt
    }
}
```

> **확장 여지(이번 미포함)**: 반복(`recurrenceRule`), 태그(`tags`)는 Could 단계에서 별도 필드/엔티티로 추가. 현재 스키마에는 넣지 않는다.

## 5. 알림 스케줄링 흐름

| 이벤트 | 처리 |
|--------|------|
| 항목 저장(notifyAt 有) | `NotificationScheduler.schedule(task)` — identifier=task.id |
| 항목 수정 | 기존 알림 취소 후 재예약 |
| 완료/삭제 | `NotificationScheduler.cancel(task.id)` |
| 권한 없음 | 권한 요청, 거부 시 설정 안내 배너 |
| 과거 시각 | 예약 스킵 |

## 6. 폴더 구조 제안

```
Dasibom/
├── App/
│   └── DasibomApp.swift           // @main, ModelContainer 설정
├── Models/
│   └── Task.swift                 // @Model
├── Views/
│   ├── Main/
│   │   ├── MainView.swift
│   │   ├── QuickInputBar.swift
│   │   └── TaskRow.swift
│   ├── Edit/
│   │   └── TaskEditView.swift
│   └── Settings/
│       └── SettingsView.swift
├── ViewModels/
│   └── MainViewModel.swift
├── Services/
│   ├── NaturalLanguageParser.swift
│   └── NotificationScheduler.swift
└── Resources/
    └── Assets.xcassets
```

## 7. 의존성 방향

```
View ──▶ ViewModel ──▶ Service ──▶ (System APIs: UserNotifications)
  │            │
  └────────────┴──▶ SwiftData (@Model / ModelContext)
```

- 단방향 의존: View는 ViewModel만, ViewModel은 Service/Store만 안다.
- Service는 UI를 모른다(테스트 용이).
