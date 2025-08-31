import Foundation

enum Route: Hashable {
    case compose
    case results(original: String, items: [PolishedResult], draft: EmailDraft)
}
