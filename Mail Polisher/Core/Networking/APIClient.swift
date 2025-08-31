import Foundation

protocol APIClient {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

enum APIError: Error { case badStatus, decodeFailed }

// Real HTTP client for iOS
final class DefaultAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // Build URL with path + query
        guard var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.badStatus
        }
        let epPath = endpoint.path.hasPrefix("/") ? endpoint.path : "/\(endpoint.path)"
        comps.path = epPath
        comps.queryItems = endpoint.queryItems

        guard let url = comps.url else { throw APIError.badStatus }

        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method
        req.httpBody = endpoint.body
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus
        }
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw APIError.decodeFailed }
    }
}
