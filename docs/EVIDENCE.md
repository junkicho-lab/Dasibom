# 증거 보고서 — 다시봄 MVP (LOOP "완료 = 증거")

> "구현 완료"는 증거 없이는 미완료. 아래는 실제 명령 출력 기반.

## ■ 무엇을 구현했나 (15/15 태스크)
- **P0** Xcode 프로젝트(SwiftUI, iOS 17, XcodeGen) + SwiftData ModelContainer
- **P1-R1** `Item` @Model + `ItemStore`(CRUD·today/upcoming/someday)
- **P1-R2** `NaturalDateParser`("내일 3시 치과"→제목+시각, 실패 graceful)
- **P1-R3** `NotificationService`(권한·스케줄·취소, 순수 로직 분리)
- **P2-S1** 메인(빠른 입력바·오늘/예정/언젠가 리스트·완료 체크)
- **P2-S2** 추가/편집(옵셔널 날짜·알림, 빈 제목 차단, 삭제)
- **P2-S3** 설정(알림 기본값·리드타임·권한 안내) + 메인 연동

## ■ §1 필수 통과 (실제 출력)
- `** BUILD SUCCEEDED **` (iOS Simulator)
- `** TEST SUCCEEDED **` — `Executed 14 tests, with 0 failures`
  - ItemStoreTests 4 · NaturalDateParserTests 6 · NotificationServiceTests 4
- Dasibom.app 산출·코드서명 확인

## ■ 측정
- 단위 테스트 14개 (데이터·파서·알림 로직). UI는 시뮬레이터 실행으로 검증.

## ■ 평가 (스펙 대조)
- Must 4종 전부 구현·동작: 빠른 입력 / 오늘·예정 뷰 / 알림 / 완료 체크
- 빈 상태·실패(파싱 실패 graceful·빈 제목 차단) 처리됨
- Won't(월간 캘린더·공유) 미구현 유지 ✅ (스코프 준수)

## ■ 참조 문서 대조
- 화면 needs ↔ Item 필드: screen-spec ICV 100%, 코드도 일치(드리프트 없음)
- 데이터 모델 = 06-tasks / resources.yaml과 동일(Item 6필드)

## ■ 시뮬레이터 실행 증거
- `docs/screenshot-main.png` — 오늘/예정/언젠가 리스트 동작
- `docs/screenshot-main2.png` — 설정 진입(기어) + 알림 권한 다이얼로그(R3)

## ■ 🚨 사람 확인된 경계선 항목
- 알림 권한 요청(UserNotifications) — 진행 동의받음
- SwiftData 스키마는 Item 최소 6필드로 확정(반복·태그는 Could, 미반영)

## ■ Could 기능 추가 (2026-06-23, 반복일정·위젯)
- **반복일정**: Item에 옵셔널 `recurrence` 추가(라이트웨이트 마이그레이션) + `RecurrenceEngine`(매일·평일·매주요일·매월) + 완료 시 다음 발생 굴림 + 편집 UI + 리스트 반복 아이콘.
- **위젯**: WidgetKit medium 위젯(오늘 할 일) + App Group(`group.com.dasibom.app`) 스냅샷 공유.
- **증거**:
  - `** BUILD SUCCEEDED **` (앱 + 위젯 extension, App Group 엔타이틀먼트)
  - `** TEST SUCCEEDED **` — `Executed 20 tests, 0 failures` (반복 6개 추가)
  - App Group 스냅샷 JSON 기록 확인 — 남은 개수 2, 항목 [팀 회의, 치과 예약, 엄마 생신 선물 사기]
  - `docs/screenshot-recurring.png` — 반복 아이콘(⟳) 표시 확인
- **마이그레이션 안전**: 추가 옵셔널 필드만 → 기존 데이터 보존(🚨 스키마 변경, 사람 확인됨).

## ■ 남은 리스크 / 미완(의도적)
- 데모 시드(`-seedDemo`)는 개발용 — 출시 전 제거 권장
- 타임존/DST 경계 추가 테스트 여지
- Could(반복 일정·태그·외부 연동·위젯)는 차기 버전
- trinity/sync 등 검증 스킬은 Python/JS 도구 기반이라 Swift엔 부분 적용(수동 검증으로 대체)
