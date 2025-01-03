import Foundation

@MainActor
final class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: String = "0.00 €"
    @Published var recentTransactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchAccountDetails() async {
        isLoading = true
        do {
            let response: AccountDetailsResponse = try await networkService.sendRequest(endpoint: .account)
            
            self.totalAmount = String(format: "%.2f€", response.currentBalance)
            self.recentTransactions = response.transactions.prefix(3).map {
                Transaction(description: $0.label, amount: String(format: "%+.2f€", $0.value))
            }
            self.isLoading = false
            
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
}
