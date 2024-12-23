import XCTest
@testable import Aura

@MainActor
final class MoneyTransferViewModelTests: XCTestCase {
    private var mockSession: URLSession!
    private var viewModel: MoneyTransferViewModel!

    override func setUp() {
        super.setUp()
        
        // Configurez une session avec MockURLProtocol
        mockSession = makeMockSession()
        let networkService = NetworkService(session: mockSession)
        
        viewModel = MoneyTransferViewModel(networkService: networkService)
    }

    override func tearDown() {
        // Réinitialisez MockURLProtocol pour éviter les interférences entre tests
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
        mockSession = nil
        viewModel = nil
        super.tearDown()
    }

    func testInvalidRecipientShowsError() async {
        // Given
        viewModel.recipient = "invalidRecipient"
        viewModel.amount = "100"

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertEqual(viewModel.alertMessage, AuraError.invalidRecipient.errorMessage)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testInvalidAmountShowsError() async {
        // Given
        viewModel.recipient = "test@example.com"
        viewModel.amount = "-50"

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertEqual(viewModel.alertMessage, AuraError.invalidAmount.errorMessage)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testEmptyAmountShowsError() async {
        // Given
        viewModel.recipient = "test@example.com"
        viewModel.amount = ""

        // When
        await viewModel.sendMoney()
        
        // Then
        XCTAssertEqual(viewModel.alertMessage, AuraError.invalidAmount.errorMessage)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSendMoneySuccess() async {
        // Given
        viewModel.recipient = "test@example.com"
        viewModel.amount = "100"
        
        // Configurez MockURLProtocol pour simuler une réponse 200
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/transfer")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.responseData = nil  // Pas de corps de réponse nécessaire pour ce cas

        // When
        await viewModel.sendMoney()
        
        // Then
        XCTAssertEqual(viewModel.transferMessage, "Successfully transferred 100€ to test@example.com.")
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSendMoneyNotFoundError() async {
        // Given
        viewModel.recipient = "test@example.com"
        viewModel.amount = "100"
        
        // Configurez MockURLProtocol pour simuler une erreur 404 Not Found
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/transfer")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertEqual(viewModel.alertMessage, AuraError.notFound.errorMessage)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSendMoneyUnknownError() async {
        // Given
        viewModel.recipient = "test@example.com"
        viewModel.amount = "100"
        
        // Configurez MockURLProtocol pour simuler une erreur inconnue
        MockURLProtocol.error = NSError(domain: "Unknown", code: 0, userInfo: nil)

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertEqual(viewModel.alertMessage, "Une erreur inconnue est survenue.")
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
}
