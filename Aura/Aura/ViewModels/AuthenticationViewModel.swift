import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let onLoginSucceed: (() -> ())
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
        _ callback: @escaping () -> ()) {
        self.networkService = networkService
        self.onLoginSucceed = callback
    }
    
    // MARK: - Login
    func login() async {
        if let error = validateCredentials() {
            alertMessage = error.errorMessage
            showAlert = true
            return
        }
        
        do {
            let response: AuthResponse = try await self.networkService.sendRequest(
                endpoint: APIEndpoint.auth(email: username, password: password))
            
            self.networkService.setAuthToken(response.token)
            onLoginSucceed()
        } catch let error as AuraError {
            alertMessage = error.errorMessage
            showAlert = true
        } catch {
            alertMessage = "Une erreur inconnue est survenue."
            showAlert = true
        }
    }
    
    // MARK: - Credentials validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validateCredentials() -> AuraError? {
        guard isValidEmail(username) else {
            return .invalidEmail
        }
        
        guard !password.isEmpty else {
            return .emptyPassword
        }
        
        return nil
    }
}
