import Foundation

@MainActor
final class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func sendMoney() async {
        if let error = validateInputs() {
            alertMessage = error.errorMessage
            showAlert = true
            return
        }
        
        await performTransfer()
    }
    
    private func performTransfer() async {
        isLoading = true
        
        do {
            let transferRequest = TransferRequest(recipient: recipient, amount: Double(amount)!)
            try await networkService.sendVoidRequest(endpoint: .transfer(request: transferRequest))
            
            transferMessage = "Successfully transferred \(amount)€ to \(recipient)."
            isLoading = false
        } catch let error as AuraError {
            alertMessage = error.errorMessage
            isLoading = false
            showAlert = true
        } catch {
            alertMessage = "Une erreur inconnue est survenue."
            isLoading = false
            showAlert = true
        }
    }
    
    // MARK: - Input validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^\\+33[1-9][0-9]{8}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    private func validateInputs() -> AuraError? {
        let isValidEmail = isValidEmail(recipient)
        let isValidPhone = isValidPhone(recipient)
        
        guard isValidEmail || isValidPhone else {
            return .invalidRecipient
        }
        
        guard let transferAmount = Double(amount), transferAmount > 0 else {
            return .invalidAmount
        }
        
        return nil
    }
}
