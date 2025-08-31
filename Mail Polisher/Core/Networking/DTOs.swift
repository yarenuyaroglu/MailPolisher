import Foundation

// MARK: - Requests

struct ServerPolishRequestDTO: Codable {
    let text: String?
    let tone: String?
    let domain: String?
    let language: String?
    let empathy: Int?
    let instructions: String?
    let previous_polished: String?
    let incoming_mail: String?
    let session_id: String?
}

// MARK: - Responses

struct ServerPolishResponseDTO: Codable {
    let polished_text: String
    let suggestions: [String]?
    let session_id: String?
    let error: String?
}

struct ServerSuggestionsResponseDTO: Codable {
    let suggestions: [String]
    let current_length: Int?
    let session_id: String
}

struct CommandHistoryItem: Codable, Hashable {
    let command: String
    let actions: [String]
    let timestamp: Double
    let explanation: String?
}

struct ServerCommandHistoryDTO: Codable {
    let session_id: String
    let commands: [CommandHistoryItem]
    let total_commands: Int
}

struct EmptyResponse: Codable {}
