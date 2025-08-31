import Foundation

struct PolishedResult: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    var text: String

    init(id: UUID = .init(), text: String) {
        self.id = id
        self.text = text
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
