import XCTest
@testable import Aura

@MainActor
final class AccountDetailViewModelTests: XCTestCase {
    private var mockNetworkService: MockNetworkService!
    private var viewModel: AccountDetailViewModel!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = AccountDetailViewModel(networkService: mockNetworkService)
    }

    override func tearDown() {
        mockNetworkService = nil
        viewModel = nil
        super.tearDown()
    }

    func testFetchAccountDetailsSuccess() async {
        // Given
        let mockTransactions = [
            AccountDetailsResponse.Transaction(value: -50.75, label: "Groceries"),
            AccountDetailsResponse.Transaction(value: 2000.00, label: "Salary"),
            AccountDetailsResponse.Transaction(value: -30.00, label: "Gym"),
            AccountDetailsResponse.Transaction(value: -15.00, label: "Coffee")
        ]
        let mockResponse = AccountDetailsResponse(currentBalance: 1234.56, transactions: mockTransactions)
        mockNetworkService.mockResponse = mockResponse

        // When
        await viewModel.fetchAccountDetails()

        // Then
        XCTAssertEqual(viewModel.totalAmount, "1234.56€")
        XCTAssertEqual(viewModel.recentTransactions.count, 3)
        XCTAssertEqual(viewModel.recentTransactions[0].description, "Groceries")
        XCTAssertEqual(viewModel.recentTransactions[0].amount, "-50.75€")
        XCTAssertEqual(viewModel.recentTransactions[1].description, "Salary")
        XCTAssertEqual(viewModel.recentTransactions[1].amount, "+2000.00€")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, "")
    }
    
    func testFetchAccountDetailsNotFoundError() async {
        // Given
        mockNetworkService.mockError = AuraError.notFound

        // When
        await viewModel.fetchAccountDetails()

        // Then
        XCTAssertEqual(viewModel.totalAmount, "0.00 €")
        XCTAssertTrue(viewModel.recentTransactions.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.notFound.errorMessage)
    }

    func testFetchAccountDetailsUnknownError() async {
        // Given
        mockNetworkService.mockError = NSError(domain: "Unknown", code: 0, userInfo: nil)

        // When
        await viewModel.fetchAccountDetails()

        // Then
        XCTAssertEqual(viewModel.totalAmount, "0.00 €")
        XCTAssertTrue(viewModel.recentTransactions.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, "Une erreur inconnue est survenue.")
    }
}
