import XCTest
@testable import Aura

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
    private var mockSession: URLSession!
    private var viewModel: AuthenticationViewModel!
    private var loginSucceededCalled: Bool!
    
    override func setUp() {
        super.setUp()
        
        mockSession = makeMockSession()
        let networkService = NetworkService(session: mockSession)
        
        loginSucceededCalled = false
        viewModel = AuthenticationViewModel(networkService: networkService) {
            self.loginSucceededCalled = true
        }
    }
    
    override func tearDown() {
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
        mockSession = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testSuccessfulLogin() async {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password123"
        
        let mockResponse = AuthResponse(token: "mockToken")
        let mockData = try! JSONEncoder().encode(mockResponse)
        
        MockURLProtocol.responseData = mockData
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/auth")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertTrue(loginSucceededCalled)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, "")
    }
    
    func testUnauthorizedErrorShowsAlert() async {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password123"
        
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/auth")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertFalse(loginSucceededCalled)
        XCTAssertEqual(viewModel.alertMessage, AuraError.unauthorized.errorMessage)
        XCTAssertTrue(viewModel.showAlert)
    }
    
    func testValidationError() async {
        // Given
        viewModel.username = "invalid_email"
        viewModel.password = "password123"
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertEqual(viewModel.alertMessage, AuraError.invalidEmail.errorMessage)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertFalse(loginSucceededCalled)
    }
}
