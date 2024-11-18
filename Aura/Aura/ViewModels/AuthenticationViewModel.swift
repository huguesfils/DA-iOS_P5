import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    // MARK: - Login
    func login() async {
        guard validateCredentials() else { return }
        
        let loginData = ["username": username, "password": password]
        
        do {
            let response: AuthResponse = try await NetworkService.shared.sendRequest(
                endpoint: .auth,
                body: loginData
                //TODO: Parametre dans l' enum du endpoint
            )
            NetworkService.shared.setAuthToken(response.token)
            onLoginSucceed()
        } catch let error as NetworkError {
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
    
    private func validateCredentials() -> Bool {
        guard isValidEmail(username) else {
            self.alertMessage = "Adresse e-mail invalide"
            self.showAlert = true
            return false
        }
        
        guard !password.isEmpty else {
            self.alertMessage = "Mot de passe invalide"
            self.showAlert = true
            return false
        }
        //TODO: améliorer l'alert password invalid
        return true
    }
}
