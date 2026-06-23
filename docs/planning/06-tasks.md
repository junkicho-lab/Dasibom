# 06 · TASKS — 다시봄 (Domain-Guarded)

> `/auto-orchestrate` 입력 계약. iOS 로컬 앱이라 "Resource" = 로컬 데이터/서비스 레이어.
> 규칙: Phase 1+ 태스크는 **TDD(RED→GREEN→REFACTOR)**. 🚨 = STOP & ASK 경계선(사람 확인).

## Interface Contract Validation (Phase 2)
- 화면 needs ↔ `items`(id·title·dueAt·notifyAt·isDone·createdAt) → **커버리지 100% ✅** (screen-spec에서 검증)
- `app_settings`(notifyByDefault·defaultLeadMinutes) → UserDefaults, 도메인 외 ✅
→ 불일치 없음, 진행.

---

## P0 — 셋업 (의존성 없음)

| ID | 태스크 | 완료 조건 |
|---|---|---|
| P0-T0.1 | Xcode 프로젝트 생성(SwiftUI, **iOS 17**, SwiftData 활성) + 폴더 구조(`Models/ Views/ ViewModels/ Services/ Utils/`) + .gitignore | 빈 앱 빌드 성공 |
| P0-T0.2 | SwiftData `ModelContainer` 앱 진입점 연결 | 앱 실행 시 컨테이너 초기화, exit 0 |

## P1 — 데이터·공통 레이어 (Resource, TDD)

| ID | 태스크 | 완료 조건 | 의존 |
|---|---|---|---|
| P1-R1-T1 | `Item` @Model (id,title,dueAt?,notifyAt?,isDone,createdAt) | 모델 단위테스트: 생성·완료토글(isDone, **삭제 아님**)·옵셔널 날짜 | P0 |
| P1-R1-T2 | `ItemStore` (SwiftData CRUD + `today`/`upcoming`/`someday` 쿼리) | 쿼리 테스트(정렬·필터), 영속 확인 | P1-R1-T1 |
| P1-R2-T1 | `NaturalDateParser` ("내일 3시 치과"→title+dueAt) | 파싱 테스트 + **실패 graceful**(제목만 반환) · 🚨 구현 방식은 spike 후 결정 | P0 |
| P1-R3-T1 | `NotificationService` (UserNotifications 권한·스케줄·취소) | 스케줄/취소 테스트 · 🚨 **알림 권한 흐름은 사람 확인** | P0 |

## P2 — 화면 (Screen, TDD)

### S1 메인
| ID | 태스크 | 완료 조건 | 의존 |
|---|---|---|---|
| P2-S1-T1 | 메인 뷰: 오늘/예정/언젠가 섹션 리스트(ItemStore 바인딩) | 쿼리별 섹션 렌더, 빈 상태 안내 | P1-R1·R2 |
| P2-S1-T2 | 상단 빠른 입력바(파서 연동, 즉시 저장, 입력바 클리어) | "내일 3시 치과"→즉시 목록 노출, 1초 입력 | P1-R2-T1, P2-S1-T1 |
| P2-S1-T3 | 완료 체크(isDone 토글, 목록 정리) | 체크→완료, 레코드 유지 | P2-S1-T1 |
| **P2-S1-V** | 메인 연결점 검증 | 입력→노출→알림→체크 흐름 + 빈 상태 통과 | 위 전부 |

### S2 추가/편집
| ID | 태스크 | 완료 조건 | 의존 |
|---|---|---|---|
| P2-S2-T1 | 추가/편집 폼(제목 필수, 옵셔널 날짜·알림, 파싱실패 안내, 삭제) | 생성·수정·삭제 + 빈 제목 차단 테스트 | P1-R1·R3 |
| **P2-S2-V** | 추가/편집 검증 | 생성→메인 반영, 파싱 실패 시 흐름 안 막힘 | P2-S2-T1 |

### S3 설정·알림
| ID | 태스크 | 완료 조건 | 의존 |
|---|---|---|---|
| P2-S3-T1 | 설정(알림 기본 on/off·리드타임 UserDefaults) + 권한 안내 | 기본값 변경 반영, 권한 거부 안내 | P1-R3-T1 |
| P2-S3-T2 | 저장 시 알림 스케줄 연동(notifyAt 등록/취소) | 항목 저장→알림 등록, 완료/삭제→취소 | P2-S3-T1, P2-S2-T1 |
| **P2-S3-V** | 설정·알림 검증 | 알림 발송·탭→항목 이동 | 위 전부 |

---

## 병렬/직렬
- P1: R1 먼저 → R2·R3는 R1과 독립이라 병렬 가능.
- P2: 각 화면은 P1 완료 후. 같은 화면의 V(검증)는 그 화면 태스크 전부 완료 후(직렬).

## 완료(증거) 게이트 — 각 V 및 최종
build✅ · XCTest✅(0 실패) · 시뮬레이터 수동 검증(핵심 흐름) · 🟦성역 점검(로컬 저장·1초 입력 유지). 상세: `LOOP.template`.

## 🚨 이 프로젝트의 STOP & ASK 지점
- SwiftData 스키마(@Model) 변경 / 마이그레이션
- 알림 권한 정책 · 데이터 외부 전송(=성역 침범)
- Won't(월간 캘린더·공유) 끼워넣기 / Could(반복·태그) 스코프 확대
