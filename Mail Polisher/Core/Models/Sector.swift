import Foundation

enum Sector: String, CaseIterable, Identifiable, Codable {
    case business = "Business"
    case academia = "Academia"
    case general = "General"

    var id: String { rawValue }
}
