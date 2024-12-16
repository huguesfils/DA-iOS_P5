import Foundation
@testable import Aura

final class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var mockError: Error?
    var capturedAuthToken: String?
    
    func setAuthToken(_ token: String) {
        capturedAuthToken = token
    }
    
    func clearAuthToken() {
        capturedAuthToken = nil
    }
    
    func sendRequest<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse as? T else {
            throw AuraError.decodingError
        }
        return response
    }
    
    func sendVoidRequest(endpoint: APIEndpoint) async throws {
        if let error = mockError {
            throw error
        }
    }
}
