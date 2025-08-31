import Foundation

enum Tone: String, CaseIterable, Identifiable, Codable {
    case formal = "Formal"
    case friendly = "Friendly"
    case direct = "Direct"
    case apologetic = "Apologetic"

    var id: String { rawValue }

    /// Short description for tooltips / captions
    var helpText: String {
        switch self {
        case .formal:
            return "Formal tone, uses 'Dear', concise and clear."
        case .friendly:
            return "Warm and approachable tone, starts with 'Hi' or 'Hello'."
        case .direct:
            return "Gets to the point quickly; minimal hedging."
        case .apologetic:
            return "Expresses apology, high empathy, takes responsibility."
        }
    }
}
