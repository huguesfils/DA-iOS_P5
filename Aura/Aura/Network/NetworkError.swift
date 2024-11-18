import Foundation

enum NetworkError: Error {
    case badURL
    case unauthorized
    case notFound
    case serverError
    case decodingError
    case unknownError(statusCode: Int)
    case customError(message: String)
    
    var errorMessage: String {
        switch self {
        case .badURL:
            return "URL invalide."
        case .unauthorized:
            return "Accès non autorisé. Veuillez vérifier vos identifiants."
        case .notFound:
            return "Ressource non trouvée."
        case .serverError:
            return "Erreur interne du serveur."
        case .decodingError:
            return "Erreur lors du décodage des données."
        case .unknownError(let statusCode):
            return "Erreur inconnue. Code de statut: \(statusCode)"
        case .customError(let message):
            return message
        }
    }
}
