import Foundation

class AppViewModel: ObservableObject {
    @Published var isLogged: Bool
    
    init() {
        isLogged = false
    }
    
    var authenticationViewModel: AuthenticationViewModel {
        return AuthenticationViewModel { [weak self] in
            self?.isLogged = true
        }
    }
    
    var accountDetailViewModel: AccountDetailViewModel {
        return AccountDetailViewModel()
    }
}
