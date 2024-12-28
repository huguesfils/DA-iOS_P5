import XCTest
@testable import Aura

@MainActor
final class MoneyTransferViewModelTests: XCTestCase {
    var viewModel: MoneyTransferViewModel!
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

    func testSendMoney_Success() async {
        // Given
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/transfer")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.error = nil

        let networkService = NetworkService(session: mockSession)
        viewModel = MoneyTransferViewModel(networkService: networkService)

        // Configure inputs
        viewModel.recipient = "test@example.com"
        viewModel.amount = "100.0"

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertEqual(viewModel.transferMessage, "Successfully transferred 100.0€ to test@example.com.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showAlert)
    }

    func testSendMoney_InvalidRecipient() async {
        // Given
        let networkService = NetworkService(session: mockSession)
        viewModel = MoneyTransferViewModel(networkService: networkService)

        // Configure invalid recipient
        viewModel.recipient = "invalidRecipient"
        viewModel.amount = "100.0"

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.invalidRecipient.errorMessage)
    }

    func testSendMoney_InvalidAmount() async {
        // Given
        let networkService = NetworkService(session: mockSession)
        viewModel = MoneyTransferViewModel(networkService: networkService)

        // Configure invalid amount
        viewModel.recipient = "test@example.com"
        viewModel.amount = "-50.0"

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.invalidAmount.errorMessage)
    }

    func testSendMoney_ServerError() async {
        // Given
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/transfer")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.error = nil

        let networkService = NetworkService(session: mockSession)
        viewModel = MoneyTransferViewModel(networkService: networkService)

        // Configure valid inputs
        viewModel.recipient = "test@example.com"
        viewModel.amount = "100.0"

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, AuraError.serverError.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSendMoney_UnknownError() async {
        // Given
        MockURLProtocol.error = NSError(domain: "", code: -1, userInfo: nil)

        let networkService = NetworkService(session: mockSession)
        viewModel = MoneyTransferViewModel(networkService: networkService)

        // Configure valid inputs
        viewModel.recipient = "test@example.com"
        viewModel.amount = "100.0"

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, "Une erreur inconnue est survenue.")
        XCTAssertFalse(viewModel.isLoading)
    }
}
