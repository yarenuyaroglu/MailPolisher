import Foundation

struct Endpoint {
    let path: String
    let method: String
    let body: Data?
    let queryItems: [URLQueryItem]?

    init(path: String, method: String = "POST", body: Data? = nil, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.method = method
        self.body = body
        self.queryItems = queryItems
    }
}

extension Endpoint {
    static func polish(_ dto: Encodable, sessionId: String? = nil) throws -> Endpoint {
        let data = try JSONEncoder().encode(AnyEncodable(dto))
        let q = sessionId.map { [URLQueryItem(name: "session", value: $0)] }
        return Endpoint(path: "/polish", method: "POST", body: data, queryItems: q)
    }

    static func suggestions(sessionId: String) -> Endpoint {
        Endpoint(path: "/suggestions/\(sessionId)", method: "GET", body: nil)
    }

    static func commandHistory(sessionId: String) -> Endpoint {
        Endpoint(path: "/history/\(sessionId)", method: "GET", body: nil)
    }

    static func clearSession(sessionId: String) -> Endpoint {
        Endpoint(path: "/session/\(sessionId)", method: "DELETE", body: nil)
    }
}

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) { _encode = value.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
