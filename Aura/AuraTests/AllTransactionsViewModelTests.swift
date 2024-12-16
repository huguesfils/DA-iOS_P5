import XCTest
@testable import Aura

@MainActor
final class AllTransactionsViewModelTests: XCTestCase {
    private var mockNetworkService: MockNetworkService!
    private var viewModel: AllTransactionsViewModel!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = AllTransactionsViewModel(networkService: mockNetworkService)
    }

    override func tearDown() {
        mockNetworkService = nil
        viewModel = nil
        super.tearDown()
    }

    func testFetchAllTransactionsSuccess() async {
        // Given
        let mockTransactions = [
            AccountDetailsResponse.Transaction(value: -50.75, label: "Groceries"),
            AccountDetailsResponse.Transaction(value: 2000.00, label: "Salary"),
            AccountDetailsResponse.Transaction(value: -30.00, label: "Gym")
        ]
        let mockResponse = AccountDetailsResponse(currentBalance: 500.0, transactions: mockTransactions)
        mockNetworkService.mockResponse = mockResponse

        // When
        await viewModel.fetchAllTransactions()

        // Then
        XCTAssertEqual(viewModel.transactions.count, 3)
        XCTAssertEqual(viewModel.transactions[0].description, "Groceries")
        XCTAssertEqual(viewModel.transactions[0].amount, "-50.75€")
        XCTAssertEqual(viewModel.transactions[1].description, "Salary")
        XCTAssertEqual(viewModel.transactions[1].amount, "+2000.00€")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, "")
    }
    
    func testFetchAllTransactionsNotFoundError() async {
        // Given
        mockNetworkService.mockError = AuraError.notFound

        // When
        await viewModel.fetchAllTransactions()

        // Then
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.notFound.errorMessage)
    }
    
    func testFetchAllTransactionsUnknownError() async {
        // Given
        mockNetworkService.mockError = NSError(domain: "Unknown", code: 0, userInfo: nil)

        // When
        await viewModel.fetchAllTransactions()

        // Then
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, "Une erreur inconnue est survenue.")
    }
}
