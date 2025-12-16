import Foundation

public class NMLoginViewModel {
    
    public init() {}
    
    // MARK: - Inputs
    
    func didEnterEmail(_ email: String) {
        // TODO: Validate email and start auto-discovery
        print("ViewModel received email: \(email)")
    }
}
