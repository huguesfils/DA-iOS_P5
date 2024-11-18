import Foundation

final class NetworkService {
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
        endpoint: APIEndpoint,
        body: Encodable? = nil
    ) async throws -> T {
        
        guard let url = URL(string: baseURL + endpoint.rawValue) else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let token = authToken {
            request.setValue(token, forHTTPHeaderField: "token")
        }
      
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError(statusCode: -1)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
            
        case 404:
            throw NetworkError.notFound
            
        case 500...599:
            throw NetworkError.serverError
            
        default:
            throw NetworkError.unknownError(statusCode: httpResponse.statusCode)
        }
    }
}
