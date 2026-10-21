import Foundation

// MARK: - Client Réseau « Viple & Moi » (Connecté à api.viple.digital & espace-client-v2.viplenetwork.com)

@MainActor
public final class VipleEtMoiAPIClient {
    public static let shared = VipleEtMoiAPIClient()

    public let primaryBaseURL = "https://api.viple.digital/api/v1/espace-client"
    public let secondaryBaseURL = "https://espace-client-v2.viplenetwork.com/api/v1/espace-client"

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 40
        self.session = URLSession(configuration: cfg)
        self.decoder = JSONDecoder()
    }

    public func fetchBootstrap(email: String?) async throws -> VipleEtMoiBootstrapResponse {
        var comps = URLComponents(string: "\(primaryBaseURL)/bootstrap")!
        if let email, !email.isEmpty {
            comps.queryItems = [URLQueryItem(name: "email", value: email)]
        }
        return try await getJSON(comps.url!)
    }

    public func postJSON<T: Decodable>(_ path: String, body: [String: Any]) async throws -> T {
        let url = URL(string: "\(primaryBaseURL)\(path)")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: req)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = dict["error"] as? String {
                throw NSError(domain: "VipleEtMoiAPI", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
            }
            throw NSError(domain: "VipleEtMoiAPI", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur serveur (\(http.statusCode))"])
        }
        return try decoder.decode(T.self, from: data)
    }

    public func postRaw(_ path: String, body: [String: Any]) async throws -> [String: Any] {
        let url = URL(string: "\(primaryBaseURL)\(path)")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: req)
        let dict = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let msg = (dict["error"] as? String) ?? "Erreur lors de l'opération."
            throw NSError(domain: "VipleEtMoiAPI", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }
        return dict
    }

    private func getJSON<T: Decodable>(_ url: URL) async throws -> T {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, _) = try await session.data(for: req)
        return try decoder.decode(T.self, from: data)
    }
}
