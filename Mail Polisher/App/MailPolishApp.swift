import SwiftUI

@main
struct MailPolishApp: App {
    @StateObject private var router = Router()

    var body: some Scene {
        WindowGroup {
            // Use live backend instead of a mock:
            let env = AppEnvironment.makeLocal()
            ComposeView(vm: ComposeViewModel(repo: env.polishingRepo, router: router))
                .environmentObject(router)
        }
    }
}
