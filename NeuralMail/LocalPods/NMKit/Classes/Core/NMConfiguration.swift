import Foundation

public class NMConfiguration {
    public static let shared = NMConfiguration()
    
    // MARK: - Environment
    
    public enum Environment {
        case development
        case staging
        case production
    }
    
    public var environment: Environment = .development
    
    // MARK: - API Endpoints
    
    public var apiBaseURL: URL {
        switch environment {
        case .development:
            return URL(string: "https://dev-api.neuralmail.com")!
        case .staging:
            return URL(string: "https://staging-api.neuralmail.com")!
        case .production:
            return URL(string: "https://api.neuralmail.com")!
        }
    }
    
    // MARK: - Feature Flags
    
    public var isAIAutoReplyEnabled: Bool = true
    public var isSmartSortingEnabled: Bool = true
    
    private init() {
        
        
        
    }
}
