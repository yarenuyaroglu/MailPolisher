import Foundation

/// Repository that talks to the backend for polish/refine flows (single GPT backend).
final class LivePolishingRepository {
    private let api: APIClient
    private let sessionId: String = UUID().uuidString

    init(api: APIClient) { self.api = api }

    /// Polish (or reply) using the single /polish endpoint.
    func polish(draft: EmailDraft) async throws -> [PolishedResult] {
        let req = ServerPolishRequestDTO(
            text: draft.text.isEmpty ? nil : draft.text,
            tone: draft.tone.rawValue.lowercased(),
            domain: draft.sector.rawValue.lowercased(),
            language: "en",
            empathy: draft.empathy,
            instructions: nil,
            previous_polished: nil,
            incoming_mail: draft.incomingMail,
            session_id: nil
        )

        let endpoint = try Endpoint.polish(req, sessionId: sessionId)
        let res: ServerPolishResponseDTO = try await api.send(endpoint)
        return [PolishedResult(text: res.polished_text)]
    }

    /// Refine by sending instructions and the previous polished text to the same /polish endpoint.
    func refine(previous: String, instructions: String, draft: EmailDraft) async throws -> String {
        let req = ServerPolishRequestDTO(
            text: draft.text.isEmpty ? previous : draft.text,
            tone: draft.tone.rawValue.lowercased(),
            domain: draft.sector.rawValue.lowercased(),
            language: "en",
            empathy: draft.empathy,
            instructions: instructions,
            previous_polished: previous,
            incoming_mail: draft.incomingMail,
            session_id: nil
        )

        let endpoint = try Endpoint.polish(req, sessionId: sessionId)
        let res: ServerPolishResponseDTO = try await api.send(endpoint)
        return res.polished_text
    }

    func getSuggestions() async throws -> [String] {
        let endpoint = Endpoint.suggestions(sessionId: sessionId)
        let res: ServerSuggestionsResponseDTO = try await api.send(endpoint)
        return res.suggestions
    }

    func getCommandHistory() async throws -> [CommandHistoryItem] {
        let endpoint = Endpoint.commandHistory(sessionId: sessionId)
        let res: ServerCommandHistoryDTO = try await api.send(endpoint)
        return res.commands
    }

    func clearSession() async throws {
        let endpoint = Endpoint.clearSession(sessionId: sessionId)
        let _: EmptyResponse = try await api.send(endpoint)
    }
}
