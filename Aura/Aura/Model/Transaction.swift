import Foundation

struct Transaction: Identifiable {
    let id = UUID()
    let description: String
    let amount: String
}
