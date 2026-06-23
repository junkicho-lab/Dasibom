# 코딩 컨벤션 (Coding Convention)
> 다시봄 기획 — 코딩 컨벤션

## 1. Swift 네이밍

| 대상 | 규칙 | 예시 |
|------|------|------|
| 타입(struct/class/enum) | UpperCamelCase | `MainView`, `Task`, `NotificationScheduler` |
| 변수·함수·프로퍼티 | lowerCamelCase | `dueAt`, `scheduleNotification()` |
| 불리언 | is/has/should 접두 | `isDone`, `hasPermission` |
| 상수(전역) | lowerCamelCase | `defaultNotifyHour` |
| enum case | lowerCamelCase | `case today`, `case upcoming` |
| 프로토콜 | 명사 또는 -able/-ing | `Scheduling`, `Parsable` |

- 약어는 통일: `id`, `url`은 소문자, 타입명 내 약어는 대문자 유지(`URL`).
- 의미 명확 우선: `t`, `tmp` 같은 모호한 이름 금지.

## 2. 파일 구조

| 규칙 | 내용 |
|------|------|
| 1파일 1타입 원칙 | 한 파일에 주 타입 하나 (`Task.swift`에 `Task`) |
| 파일명 = 타입명 | `MainView.swift`, `NaturalLanguageParser.swift` |
| 폴더 분류 | App / Models / Views / ViewModels / Services / Resources |
| 작은 보조 뷰 | 같은 화면 폴더에 분리 (`TaskRow.swift`) |

## 3. SwiftUI 뷰 컨벤션

- **body는 짧게**: 복잡한 서브뷰는 `private var` 또는 별도 `View`로 추출.
- **추출 우선순위**: 반복/재사용 → 별도 파일, 일회성 분리 → `private var`.
- **수식어(modifier) 줄바꿈**: 체이닝 시 한 줄에 하나씩, 들여쓰기 정렬.
- **상태 소유 명확화**: `@State`(뷰 로컬), `@Observable` ViewModel(화면 상태), `@Query`(SwiftData), `@AppStorage`(설정값).
- **매직 넘버 금지**: 간격·크기는 상수/스타일로 정의.

```swift
// 권장 형태
struct TaskRow: View {
    let task: Task
    var onToggle: () -> Void

    var body: some View {
        HStack {
            checkButton
            titleLabel
        }
        .padding(.vertical, 8)
    }

    private var checkButton: some View { /* ... */ }
    private var titleLabel: some View { /* ... */ }
}
```

## 4. 주석 규칙

| 상황 | 규칙 |
|------|------|
| 공개 타입/함수 | 필요 시 `///` 문서 주석으로 의도 설명 |
| 비자명 로직 | "무엇"이 아니라 "왜"를 설명 |
| TODO | `// TODO: 내용` 형식, 가능하면 책임/조건 명시 |
| 금지 | 코드 그대로 반복하는 군더더기 주석 |

- 성역 관련 코드(로컬 저장, 외부 전송 없음)는 주석으로 의도 명시 권장.

## 5. 코드 스타일

- 들여쓰기: 스페이스 4칸.
- 강제 언래핑(`!`) 지양 → `guard let`/`if let` 사용.
- `guard`로 조기 반환, 중첩 최소화.
- 접근 제어자: 기본 `private`, 필요한 만큼만 공개.

## 6. 커밋 메시지 규칙

형식: `[태그] 한국어 한 줄 요약`

| 태그 | 용도 |
|------|------|
| `[기능]` | 새 기능 추가 |
| `[수정]` | 버그 수정 |
| `[개선]` | 리팩터링·성능·UX 개선 |
| `[문서]` | 문서 작성/수정 |
| `[설정]` | 빌드/프로젝트 설정 |
| `[테스트]` | 테스트 추가/수정 |

- 예: `[기능] 빠른 입력바 자연어 날짜 파싱 추가`
- 한 커밋 = 한 가지 변경(원자적).
- 본문(선택): 변경 이유와 영향 설명.
