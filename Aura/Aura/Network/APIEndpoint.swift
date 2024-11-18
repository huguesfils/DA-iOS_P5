import Foundation

enum APIEndpoint: String {
    case auth = "/auth"
    case account = "/account"
    case accountTransfer = "/account/transfer"
    
    var method: HTTPMethod {
        switch self {
        case .auth:
            return .post
        case .account:
            return .get
        case .accountTransfer:
            return .post
        }
    }
}
