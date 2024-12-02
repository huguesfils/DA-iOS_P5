import Foundation

enum APIEndpoint {
    case auth(email: String, password: String)
    case account
    case transfer(request: TransferRequest)
    
    var path: String {
        switch self {
        case .auth:
            return "/auth"
        case .account:
            return "/account"
        case .transfer:
            return "/account/transfer"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .auth:
            return .post
        case .account:
            return .get
        case .transfer:
            return .post
        }
    }
    
    var body: Encodable? {
        switch self {
        case .auth(let email, let password):
            return ["username": email, "password": password]
        case .account:
            return nil
        case .transfer(let request):
            return request
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
