import Foundation

/// 한 줄 입력에서 제목 + 날짜/시각을 뽑는다 (P1-R2).
/// 예: "내일 3시 치과" → (title: "치과", dueAt: 내일 15:00)
/// 실패 graceful: 날짜 토큰이 없으면 dueAt = nil, title = 원문(입력 절대 안 막음, 🟦성역).
struct ParsedInput: Equatable {
    var title: String
    var dueAt: Date?
}

enum NaturalDateParser {

    static func parse(_ raw: String, now: Date = .now, calendar: Calendar = .current) -> ParsedInput {
        let text = raw.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return ParsedInput(title: "", dueAt: nil) }

        var consumed: [Range<String.Index>] = []

        // 1) 날짜 키워드
        var dayOffset: Int?
        for (kw, offset) in [("오늘", 0), ("내일", 1), ("모레", 2)] {
            if let r = text.range(of: kw) { dayOffset = offset; consumed.append(r); break }
        }

        // 2) 오전/오후
        var meridiem: String?
        for kw in ["오전", "오후"] {
            if let r = text.range(of: kw) { meridiem = kw; consumed.append(r); break }
        }

        // 3) 시각  "(\d{1,2})시 (\d{1,2}분 | 반)?"
        var hour: Int?
        var minute = 0
        if let m = firstMatch(in: text, pattern: #"(\d{1,2})\s*시\s*(?:(\d{1,2})\s*분|(반))?"#) {
            hour = Int(m.group(1, in: text) ?? "")
            if let mm = m.group(2, in: text), let v = Int(mm) { minute = v }
            else if m.group(3, in: text) != nil { minute = 30 }   // "반"
            consumed.append(Range(m.range, in: text)!)
        }

        // 4) 날짜 조립
        var dueAt: Date?
        if dayOffset != nil || hour != nil {
            let base = calendar.startOfDay(for: now)
            let day = calendar.date(byAdding: .day, value: dayOffset ?? 0, to: base)!
            let resolvedHour = resolveHour(hour ?? 9, meridiem: meridiem) // 시간 없으면 09:00
            dueAt = calendar.date(bySettingHour: resolvedHour, minute: minute, second: 0, of: day)
        }

        // 5) 제목 = 매칭 토큰 제거 후 남은 것
        var title = text
        for r in consumed.sorted(by: { $0.lowerBound > $1.lowerBound }) {
            title.replaceSubrange(r, with: " ")
        }
        title = title.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
                     .trimmingCharacters(in: .whitespaces)
        if title.isEmpty { title = text }   // 날짜만 적었으면 원문 유지

        return ParsedInput(title: title, dueAt: dueAt)
    }

    /// 오전/오후 미지정 시: 1~7시는 오후로(약속 통념), 그 외 그대로.
    private static func resolveHour(_ h: Int, meridiem: String?) -> Int {
        switch meridiem {
        case "오후": return h < 12 ? h + 12 : h
        case "오전": return h == 12 ? 0 : h
        default:     return (1...7).contains(h) ? h + 12 : h
        }
    }

    // MARK: - regex helper
    private static func firstMatch(in text: String, pattern: String) -> NSTextCheckingResult? {
        guard let re = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        return re.firstMatch(in: text, range: range)
    }
}

private extension NSTextCheckingResult {
    func group(_ i: Int, in text: String) -> String? {
        guard i < numberOfRanges, let r = Range(range(at: i), in: text) else { return nil }
        return String(text[r])
    }
}
