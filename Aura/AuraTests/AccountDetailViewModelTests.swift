import XCTest
@testable import Aura

@MainActor
final class AccountDetailViewModelTests: XCTestCase {
    private var mockSession: URLSession!
    private var viewModel: AccountDetailViewModel!
    
    override func setUp() {
        super.setUp()
        
        mockSession = makeMockSession()
        let networkService = NetworkService(session: mockSession)
        
        viewModel = AccountDetailViewModel(networkService: networkService)
    }

    override func tearDown() {
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
        mockSession = nil
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
        let mockData = try! JSONEncoder().encode(mockResponse)
        
        MockURLProtocol.responseData = mockData
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account/details")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

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
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account/details")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

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
        MockURLProtocol.error = NSError(domain: "Unknown", code: 0, userInfo: nil)

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
