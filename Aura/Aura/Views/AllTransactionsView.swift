import SwiftUI

struct AllTransactionsView: View {
    @ObservedObject var viewModel: AllTransactionsViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading transactions...")
            } else {
                List(viewModel.transactions) { transaction in
                    HStack {
                        Image(systemName: transaction.amount.contains("+") ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                            .foregroundColor(transaction.amount.contains("+") ? .green : .red)
                        Text(transaction.description)
                        Spacer()
                        Text(transaction.amount)
                            .fontWeight(.bold)
                            .foregroundColor(transaction.amount.contains("+") ? .green : .red)
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(.plain)
            }
        }
        .task {
            await viewModel.fetchAllTransactions()
        }
        .navigationTitle("All Transactions")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Erreur"),
                  message: Text(viewModel.alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    AllTransactionsView(viewModel: AllTransactionsViewModel())
}
