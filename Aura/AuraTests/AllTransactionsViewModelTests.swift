import XCTest
@testable import Aura

@MainActor
final class AllTransactionsViewModelTests: XCTestCase {
    var viewModel: AllTransactionsViewModel!
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()
        mockSession = makeMockSession()
    }

    override func tearDown() {
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
        viewModel = nil
        super.tearDown()
    }

    func testFetchAllTransactions_Success() async {
        // Given
        let mockResponse = AccountDetailsResponse(
            currentBalance: 1500.0,
            transactions: [
                AccountDetailsResponse.Transaction(value: -50.0, label: "Groceries"),
                AccountDetailsResponse.Transaction(value: 200.0, label: "Salary"),
                AccountDetailsResponse.Transaction(value: -30.0, label: "Utilities")
            ]
        )
        MockURLProtocol.responseData = try! JSONEncoder().encode(mockResponse)
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkService = NetworkService(session: mockSession)
        viewModel = AllTransactionsViewModel(networkService: networkService)
        
        // When
        await viewModel.fetchAllTransactions()
        
        // Then
        XCTAssertEqual(viewModel.transactions.count, 3)
        XCTAssertEqual(viewModel.transactions[0].description, "Groceries")
        XCTAssertEqual(viewModel.transactions[0].amount, "-50.00€")
        XCTAssertEqual(viewModel.transactions[1].description, "Salary")
        XCTAssertEqual(viewModel.transactions[1].amount, "+200.00€")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showAlert)
    }

    func testFetchAllTransactions_ServerError() async {
        // Given
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkService = NetworkService(session: mockSession)
        viewModel = AllTransactionsViewModel(networkService: networkService)
        
        // When
        await viewModel.fetchAllTransactions()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.serverError.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFetchAllTransactions_DecodingError() async {
        // Given
        MockURLProtocol.responseData = "Invalid Data".data(using: .utf8)
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkService = NetworkService(session: mockSession)
        viewModel = AllTransactionsViewModel(networkService: networkService)
        
        // When
        await viewModel.fetchAllTransactions()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.decodingError.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFetchAllTransactions_Unauthorized() async {
        // Given
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkService = NetworkService(session: mockSession)
        viewModel = AllTransactionsViewModel(networkService: networkService)
        
        // When
        await viewModel.fetchAllTransactions()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.unauthorized.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
