import Foundation

@MainActor
final class AllTransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func fetchAllTransactions() async {
        isLoading = true
        do {
            let response: AccountDetailsResponse = try await networkService.sendRequest(endpoint: .account)
            self.transactions = response.transactions.map {
                Transaction(description: $0.label, amount: String(format: "%+.2f€", $0.value))
            }
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
}
