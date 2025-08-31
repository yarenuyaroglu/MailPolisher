import SwiftUI

final class Router: ObservableObject {
    @Published var path = NavigationPath()
    func navigate(to route: Route) { path.append(route) }
    func reset() { path = NavigationPath() } // NavigationPath has no removeAll
}
