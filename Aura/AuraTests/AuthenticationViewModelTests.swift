import XCTest
@testable import Aura

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
    var viewModel: AuthenticationViewModel!
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
    
    func testSuccessfulLogin() async throws {
        // Given
        MockURLProtocol.responseData = """
        {
            "token": "mockedToken"
        }
        """.data(using: .utf8)
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/auth")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.error = nil
        
        let networkService = NetworkService(session: makeMockSession())
        let expectation = XCTestExpectation(description: "Login success callback")
        
        viewModel = AuthenticationViewModel(networkService: networkService) {
            expectation.fulfill()
        }
        
        viewModel.username = "test@example.com"
        viewModel.password = "password123"
        
        // Then
        await viewModel.login()
        
        // When
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, "")
    }
    
    func testUnauthorizedErrorShowsAlert() async {
        // Given
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/auth")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.responseData = """
        {
            "error": "Unauthorized"
        }
        """.data(using: .utf8)
        let networkService = NetworkService(session: mockSession)
        viewModel = AuthenticationViewModel(networkService: networkService, {})
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.invalidEmail.errorMessage)
    }
    
    func testValidationError() async {
        // Given
        let networkService = NetworkService(session: mockSession)
        viewModel = AuthenticationViewModel(networkService: networkService, {})
        viewModel.username = "invalidEmail"
        viewModel.password = ""
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.invalidEmail.errorMessage)
    }
}
