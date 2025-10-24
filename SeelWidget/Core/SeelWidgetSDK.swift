import Foundation

// MARK: - Environment Enum
public enum SeelEnvironment: String {
    case development = "development"
    case production = "production"
}

public class SeelWidgetSDK {
    
    // MARK: - Singleton Instance
    public static let shared = SeelWidgetSDK()
    
    // MARK: - Properties
    private var _apiKey: String?
    private var _environment: SeelEnvironment = .production
    
    // MARK: - Public Methods
    
    /// Configure SeelWidgetSDK
    /// - Parameters:
    ///   - apiKey: API key
    ///   - environment: Environment (optional, defaults to production)
    ///   - baseURL: Custom base URL (optional)
    public func configure(apiKey: String, environment: SeelEnvironment = .production) {
        self._apiKey = apiKey
        self._environment = environment
    }
    
    /// Get current API Key
    public var apiKey: String? {
        return _apiKey
    }
    
    /// Get current environment
    public var environment: SeelEnvironment {
        return _environment
    }
    
    /// Check if configured
    public var isConfigured: Bool {
        return _apiKey != nil
    }
    
    public func createEvents(_ event: EventsRequest, completion: @escaping (Result<EventsResponse, NetworkError>) -> Void) {
        var _event = event
        _event.eventID = UUID().uuidString
        NetworkManager.shared.createEvents(_event, completion: completion)
    }
}
