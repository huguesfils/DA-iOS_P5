import XCTest
@testable import Aura

@MainActor
final class MoneyTransferViewModelTests: XCTestCase {
    private var mockNetworkService: MockNetworkService!
    private var viewModel: MoneyTransferViewModel!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = MoneyTransferViewModel(networkService: mockNetworkService)
    }

    override func tearDown() {
        mockNetworkService = nil
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
    
    func testInvalidAmountShowsError() async{
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

    func testEmptyAmountShowsError() async{
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
        mockNetworkService.mockResponse = ()

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
        mockNetworkService.mockError = AuraError.notFound

        // When
        await viewModel.sendMoney()

        // Then
        XCTAssertEqual(viewModel.alertMessage, AuraError.notFound.errorMessage)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
//    func testSendMoneyUnknownError() async {
//        // Given
//        viewModel.recipient = "test@example.com"
//        viewModel.amount = "100"
//        mockNetworkService.mockError = NSError(domain: "Unknown", code: 0, userInfo: nil)
//
//        // When
//        viewModel.sendMoney()
//        await Task.yield()
//
//        // Then
//        XCTAssertEqual(viewModel.alertMessage, "Une erreur inconnue est survenue.")
//        XCTAssertTrue(viewModel.showAlert)
//        XCTAssertFalse(viewModel.isLoading)
//    }
}
