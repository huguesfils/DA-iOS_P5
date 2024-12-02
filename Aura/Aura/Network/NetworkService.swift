import Foundation

final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private var authToken: String?
    private let baseURL = "http://127.0.0.1:8080"
    
    private init() {}
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    func sendRequest<T: Decodable>(
        endpoint: APIEndpoint
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw AuraError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let token = authToken {
            request.setValue(token, forHTTPHeaderField: "token")
        }
        
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuraError.unknownError(statusCode: -1)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            if T.self == Void.self {
                return () as! T
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw AuraError.decodingError
            }
        case 400:
            if let error = try? JSONDecoder().decode([String: String].self, from: data),
               let message = error["error"] {
                throw AuraError.customError(message: message)
            } else {
                throw AuraError.customError(message: "Requête invalide. Vérifiez vos informations.")
            }
        case 401:
            throw AuraError.unauthorized
        case 404:
            throw AuraError.notFound
        case 500...599:
            throw AuraError.serverError
        default:
            throw AuraError.unknownError(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: Protocol
protocol NetworkServiceProtocol {
    func setAuthToken(_ token: String)
    func clearAuthToken()
    func sendRequest<T: Decodable>(endpoint: APIEndpoint) async throws -> T
}
