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
             "URL invalide."
        case .unauthorized:
             "Accès non autorisé. Veuillez vérifier vos identifiants."
        case .notFound:
             "Ressource non trouvée."
        case .serverError:
             "Erreur interne du serveur."
        case .decodingError:
             "Erreur lors du décodage des données."
        case .unknownError(let statusCode):
             "Erreur inconnue. Code de statut: \(statusCode)"
        case .customError(let message):
             message
        case .invalidEmail:
             "Adresse e-mail invalide. Veuillez entrer une adresse e-mail valide."
        case .emptyPassword:
             "Le champ mot de passe est vide. Veuillez entrer un mot de passe."
        case .invalidRecipient:
             "Destinataire invalide. Veuillez entrer une adresse e-mail valide ou un numéro de téléphone français."
        case .invalidAmount:
             "Montant invalide. Veuillez entrer un montant positif."
        }
    }
}
