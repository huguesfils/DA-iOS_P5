import XCTest
@testable import Aura

@MainActor
final class AccountDetailViewModelTests: XCTestCase {
    var viewModel: AccountDetailViewModel!
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
    
    func testFetchAccountDetails_Success() async {
        // Given
        let mockResponse = AccountDetailsResponse(
            currentBalance: 1500.0,
            transactions: [
                AccountDetailsResponse.Transaction(value: -50.0, label: "Groceries"),
                AccountDetailsResponse.Transaction(value: 200.0, label: "Salary"),
                AccountDetailsResponse.Transaction(value: -30.0, label: "Utilities"),
                AccountDetailsResponse.Transaction(value: -20.0, label: "Transport")
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
        viewModel = AccountDetailViewModel(networkService: networkService)
        
        // When
        await viewModel.fetchAccountDetails()
        
        // Then
        XCTAssertEqual(viewModel.totalAmount, "1500.00€")
        XCTAssertEqual(viewModel.recentTransactions.count, 3)
        XCTAssertEqual(viewModel.recentTransactions[0].description, "Groceries")
        XCTAssertEqual(viewModel.recentTransactions[0].amount, "-50.00€")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showAlert)
    }
    
    func testFetchAccountDetails_ServerError() async {
        // Given
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkService = NetworkService(session: mockSession)
        viewModel = AccountDetailViewModel(networkService: networkService)
        
        // When
        await viewModel.fetchAccountDetails()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.serverError.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFetchAccountDetails_DecodingError() async {
        // Given
        MockURLProtocol.responseData = "Invalid Data".data(using: .utf8)
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkService = NetworkService(session: mockSession)
        viewModel = AccountDetailViewModel(networkService: networkService)
        
        // When
        await viewModel.fetchAccountDetails()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.decodingError.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFetchAccountDetails_Unauthorized() async {
        // Given
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/account")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkService = NetworkService(session: mockSession)
        viewModel = AccountDetailViewModel(networkService: networkService)
        
        // When
        await viewModel.fetchAccountDetails()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.unauthorized.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
