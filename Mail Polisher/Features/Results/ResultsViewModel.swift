import Foundation

@MainActor
final class ResultsViewModel: ObservableObject {
    // Chat messages
    @Published var messages: [ChatMessage] = []
    @Published var instructions: String = ""
    @Published var isRefining = false
    @Published var error: String?
    
    private let repo: LivePolishingRepository
    private let draftSnapshot: EmailDraft
    
    init(items: [PolishedResult], repo: LivePolishingRepository, draft: EmailDraft) {
        self.repo = repo
        self.draftSnapshot = draft
        // Seed the thread with the first assistant message
        if let first = items.first {
            messages = [ChatMessage(role: .assistant, text: first.text)]
        }
    }
    
    func applyRefine() async {
        await applyRefine(instruction: instructions, showUserBubble: true)
    }
    
    /// Shared entry for both Quick Actions and manual refine
    func applyRefine(instruction raw: String, showUserBubble: Bool = true) async {
        let inst = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !inst.isEmpty else { return }
        
        // Last assistant message we will refine on
        guard let lastAssistant = messages.last(where: { $0.role == .assistant }) else {
            error = "Generate a result first."
            return
        }
        
        // UI: show the user's instruction bubble
        if showUserBubble {
            messages.append(ChatMessage(role: .user, text: inst))
        }
        instructions = ""
        
        isRefining = true
        defer { isRefining = false }
        do {
            let newText = try await repo.refine(
                previous: lastAssistant.text,
                instructions: inst,
                draft: draftSnapshot
            )
            messages.append(ChatMessage(role: .assistant, text: newText))
        } catch {
            self.error = "Refine failed: \(error.localizedDescription)"
        }
    }
}
