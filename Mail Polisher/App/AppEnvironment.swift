import Foundation

struct AppEnvironment {
    let apiClient: APIClient
    let polishingRepo: LivePolishingRepository
    // let feedbackService: FeedbackService

    static func makeLocal() -> AppEnvironment {
        // Simulator:
        let api = DefaultAPIClient(baseURL: URL(string: "http://127.0.0.1:5000")!)
        // Real device test: "http://192.168.x.x:5000"

        let liveRepo = LivePolishingRepository(api: api)
        // let feedbackSvc = DefaultFeedbackService(store: InMemoryFeedbackStore())
        return .init(apiClient: api, polishingRepo: liveRepo)
    }
}
