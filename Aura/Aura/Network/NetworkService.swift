import Foundation

final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private var authToken: String?
    private let baseURL = "http://127.0.0.1:8080"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }

    func sendRequest<T: Decodable>(
        endpoint: APIEndpoint
    ) async throws -> T {
       
        let (data, httpStatusCode) = try await perform(endpoint: endpoint)
        
        switch httpStatusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw AuraError.decodingError
            }
        default:
            let error = handleError(httpStatusCode: httpStatusCode, data: data)
            throw error
        }
    }
    
    func sendVoidRequest(endpoint: APIEndpoint) async throws {
       
        let (data, httpStatusCode) = try await perform(endpoint: endpoint)
        
        switch httpStatusCode {
        case 200...299:
            return
        default:
            let error = handleError(httpStatusCode: httpStatusCode, data: data)
            throw error
        }
    }
    
    private func perform(endpoint: APIEndpoint) async throws -> (data: Data, response: Int) {
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

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuraError.unknownError(statusCode: -1)
        }

        return (data, httpResponse.statusCode)
    }
    
    private func handleError(httpStatusCode: Int, data: Data) -> Error {
        switch httpStatusCode {
        case 400:
            if let error = try? JSONDecoder().decode([String: String].self, from: data),
               let message = error["error"] {
                return AuraError.customError(message: message)
            } else {
                return AuraError.unauthorized
            }
        case 401:
            return AuraError.unauthorized
        case 404:
            return AuraError.notFound
        case 500...599:
            return AuraError.serverError
        default:
            return AuraError.unknownError(statusCode: httpStatusCode)
        }
    }
}

// MARK: Protocol
protocol NetworkServiceProtocol {
    func setAuthToken(_ token: String)
    func clearAuthToken()
    func sendRequest<T: Decodable>(endpoint: APIEndpoint) async throws -> T
    func sendVoidRequest(endpoint: APIEndpoint) async throws
}
