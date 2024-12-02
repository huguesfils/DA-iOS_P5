import Foundation

enum AuraError: Error {
    case badURL
    case unauthorized
    case notFound
    case serverError
    case decodingError
    case unknownError(statusCode: Int)
    case customError(message: String)
    
    case invalidEmail
    case emptyPassword
    case invalidRecipient
    case invalidAmount
    
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
        case .invalidEmail:
            return "Adresse e-mail invalide. Veuillez entrer une adresse e-mail valide."
        case .emptyPassword:
            return "Le champ mot de passe est vide. Veuillez entrer un mot de passe."
        case .invalidRecipient:
            return "Destinataire invalide. Veuillez entrer une adresse e-mail valide ou un numéro de téléphone français."
        case .invalidAmount:
            return "Montant invalide. Veuillez entrer un montant positif."
        }
    }
}
