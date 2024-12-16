import XCTest
@testable import Aura

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
    private var mockNetworkService: MockNetworkService!
    private var viewModel: AuthenticationViewModel!
    private var loginSucceededCalled: Bool!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        loginSucceededCalled = false
        viewModel = AuthenticationViewModel(networkService: mockNetworkService) {
            self.loginSucceededCalled = true
        }
    }

    override func tearDown() {
        mockNetworkService = nil
        viewModel = nil
        super.tearDown()
    }

    func testSuccessfulLogin() async {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password123"

        let mockResponse = AuthResponse(token: "mockToken")
        mockNetworkService.mockResponse = mockResponse

        // When
        await viewModel.login()

        // Then
        XCTAssertTrue(loginSucceededCalled)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertEqual(mockNetworkService.capturedAuthToken, "mockToken")
    }

    func testUnauthorizedErrorShowsAlert() async {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password123"

        mockNetworkService.mockError = AuraError.unauthorized

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
