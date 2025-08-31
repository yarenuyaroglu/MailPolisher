import Foundation

struct EmailDraft: Equatable, Codable, Hashable {
    var text: String
    var tone: Tone
    var sector: Sector
    var empathy: Int // 0...10

    /// Original body of the email we are replying to (reply mode)
    var incomingMail: String?

    static let empty = EmailDraft(
        text: "",
        tone: .formal,
        sector: .business,
        empathy: 5,
        incomingMail: nil
    )

    /// Send is enabled if either user's draft text or the incoming mail body is present
    var isValid: Bool {
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasIncoming = !(incomingMail ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasText || hasIncoming
    }
}
