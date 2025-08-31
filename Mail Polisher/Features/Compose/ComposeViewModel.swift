import Foundation

@MainActor
final class ComposeViewModel: ObservableObject {
    @Published var draft: EmailDraft = .empty
    @Published var isLoading = false
    @Published var error: String?

     let repo: LivePolishingRepository
     let router: Router

    var currentDraft: EmailDraft { draft }

    init(repo: LivePolishingRepository, router: Router) {
        self.repo = repo
        self.router = router
    }

    func polish() async {
        guard draft.isValid else {
            error = "Please enter your email (or paste the incoming email)."
            return
        }
        isLoading = true
        defer { isLoading = false }

        do {
            let results = try await repo.polish(draft: draft)
            router.navigate(to: .results(original: draft.text, items: results, draft: draft))
        } catch {
            self.error = "Could not process your request. Please try again later."
        }
    }
}
