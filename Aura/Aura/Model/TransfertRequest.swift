import Foundation

struct TransferRequest: Encodable {
    let recipient: String
    let amount: Double
}
