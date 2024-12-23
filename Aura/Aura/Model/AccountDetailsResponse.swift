import Foundation

struct AccountDetailsResponse: Decodable, Encodable {
    let currentBalance: Double
    let transactions: [Transaction]

    struct Transaction: Decodable, Encodable {
        let value: Double
        let label: String
    }
}
