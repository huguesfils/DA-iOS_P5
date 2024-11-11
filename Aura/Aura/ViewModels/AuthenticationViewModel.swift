import Foundation

class AuthenticationViewModel: ObservableObject {
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
        
        guard let url = URL(string: "http://127.0.0.1:8080/auth") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData: [String: String] = [
            "username": username,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let _ = try JSONDecoder().decode(AuthResponse.self, from: data)
                DispatchQueue.main.async {
                    self.onLoginSucceed()
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "Erreur de connexion"
                    self.showAlert = true
                }
            }
        } catch {
            print("Request error: \(error)")
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
            DispatchQueue.main.async {
                self.alertMessage = "Adresse e-mail invalide"
                self.showAlert = true
            }
            return false
        }
        
        guard !password.isEmpty else {
            DispatchQueue.main.async {
                self.alertMessage = "Mot de passe invalide"
                self.showAlert = true
            }
            return false
        }
        
        return true
    }
    
    //TODO: faire un network service qui gere les call api, le parsing... + concurrency -> plus de dispatchqueue
}
