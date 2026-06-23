# 다시봄 (Dasibom)

빨리 적고, 안 까먹게 다시 띄워주는 iOS 놓침 방지 앱.
*"알림이 없어서가 아니라, 입력이 무겁고 다시 안 봐서 놓친다"* — 그래서 **초간단 입력 + 능동 재노출**에 집중한다.

## 스택
SwiftUI · SwiftData(로컬) · UserNotifications · iOS 17+ · 백엔드 없음(로컬 우선)

## 빌드 (XcodeGen)
`.xcodeproj`는 생성물이라 git에 포함하지 않는다. `project.yml`이 정본.

```bash
brew install xcodegen        # 최초 1회
xcodegen generate            # Dasibom.xcodeproj 생성
open Dasibom.xcodeproj        # Xcode에서 실행
```

또는 CLI 빌드·테스트:
```bash
xcodebuild test -project Dasibom.xcodeproj -scheme Dasibom \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

데모 데이터로 실행(개발용): 스킴 Arguments에 `-seedDemo` 추가.

## 기능 (MVP)
- ⚡ 빠른 한 줄 입력 (자연어 날짜 인식: "내일 3시 치과")
- 📋 오늘·예정·언젠가 한눈 보기
- 🔔 제때 알림
- ✅ 완료 체크

비범위(이번 버전): 월간 캘린더 뷰, 공유·협업.

## 구조
```
project.yml              # XcodeGen 정의
Sources/
  App/ Models/ Views/ ViewModels/ Services/ Utils/
Tests/                   # XCTest (14)
docs/planning/ specs/    # 기획·화면 명세 (socrates → screen-spec → tasks-generator)
docs/{DECISIONS,EVIDENCE}.md
```

## 문서
기획·설계 결정은 `docs/planning/`, `docs/DECISIONS.md` 참조.
