import Foundation

struct AccountDetailsResponse: Decodable {
    let currentBalance: Double
    let transactions: [Transaction]

    struct Transaction: Decodable {
        let value: Double
        let label: String
    }
}
