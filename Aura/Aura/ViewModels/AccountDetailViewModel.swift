import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: String = "€12,345.67"
    @Published var recentTransactions: [Transaction] = [
        Transaction(description: "Starbucks", amount: "-€5.50"),
        Transaction(description: "Amazon Purchase", amount: "-€34.99"),
        Transaction(description: "Salary", amount: "+€2,500.00")
    ]
    
    struct Transaction {
        let description: String
        let amount: String
    }
}
