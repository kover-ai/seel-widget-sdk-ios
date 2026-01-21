import Foundation

/// Network manager responsible for encapsulating all network requests
@MainActor
class NetworkManager {
    
    // MARK: - Singleton
    public static let shared = NetworkManager()
    
    // MARK: - Private Properties
    private let seelWidgetSDK: SeelWidgetSDK
    
    // MARK: - Initialization
    private init() {
        self.seelWidgetSDK = SeelWidgetSDK.shared
    }
    
    // MARK: - Public Properties
    
    /// Get base URL
    private var baseURL: String {
        switch seelWidgetSDK.environment {
        case .development:
            return "https://api-test.seel.com"
        case .production:
            return "https://api.seel.com"
        }
    }

    /// Events endpoint base URL
    private var logBaseURL: String {
        switch seelWidgetSDK.environment {
        case .development:
            return "https://log-test.seel.com"
        case .production:
            return "https://log.seel.com"
        }
    }
    
    // MARK: - Private Methods
    
    /// Build complete URL
    private func buildURL(endpoint: String, base customBaseURL: String? = nil) -> String {
        let base = customBaseURL ?? baseURL
        let cleanEndpoint = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        return "\(base)/\(cleanEndpoint)"
    }
    
    /// Create default request configuration
    private func createDefaultConfiguration() throws -> RequestConfiguration {
        guard let apiKey = seelWidgetSDK.apiKey, !apiKey.isEmpty else {
            throw NetworkError.networkError(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key is required but not configured"]))
        }
        
        return RequestConfiguration(
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-Seel-Api-Version": Constants.version,
                "X-Seel-Api-Key": apiKey,
            ]
        )
    }
    
    // MARK: - Public Methods
    
    /// Generic POST request
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - requestBody: Request body (Codable object)
    ///   - responseType: Response type
    ///   - completion: Completion callback
    public func post<T: Codable, R: Codable & Sendable>(
        baseURL: String? = nil,
        timeoutInterval: TimeInterval? = nil,
        endpoint: String,
        requestBody: T,
        responseType: R.Type,
        completion: @escaping @Sendable (Result<R, NetworkError>) -> Void
    ) {
        do {
            var configuration = try createDefaultConfiguration()
            if let timeoutInterval = timeoutInterval {
                configuration.timeoutInterval = timeoutInterval
            }
            let request = Request(configuration: configuration)
            
            // Convert Codable object to dictionary
            let parameters: [String: Any]
            if let dict = requestBody.toDictionary() {
                parameters = dict
            } else {
                completion(.failure(.networkError(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert request body to dictionary"]))))
                return
            }
            
            request.post(
                url: buildURL(endpoint: endpoint, base: baseURL),
                parameters: parameters,
                responseType: responseType,
                completion: completion
            )
        } catch {
            completion(.failure(error as? NetworkError ?? .networkError(error)))
        }
    }
    
    /// Generic GET request
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - queryParams: Query parameters (Codable object)
    ///   - responseType: Response type
    ///   - completion: Completion callback
    public func get<T: Codable, R: Codable & Sendable>(
        baseURL: String? = nil,
        timeoutInterval: TimeInterval? = nil,
        endpoint: String,
        queryParams: T? = nil,
        responseType: R.Type,
        completion: @escaping @Sendable (Result<R, NetworkError>) -> Void
    ) {
        do {
            var configuration = try createDefaultConfiguration()
            if let timeoutInterval = timeoutInterval {
                configuration.timeoutInterval = timeoutInterval
            }
            let request = Request(configuration: configuration)
            
            // Convert Codable object to dictionary
            let parameters: [String: Any]?
            if let queryParams = queryParams {
                parameters = queryParams.toDictionary()
            } else {
                parameters = nil
            }
            
            request.get(
                url: buildURL(endpoint: endpoint, base: baseURL),
                parameters: parameters,
                responseType: responseType,
                completion: completion
            )
        } catch {
            completion(.failure(error as? NetworkError ?? .networkError(error)))
        }
    }
}

extension NetworkManager {
    
    public func createQuote(_ quote: QuotesRequest, completion: @escaping @Sendable (Result<QuotesResponse, NetworkError>) -> Void) {
        post(
            timeoutInterval: 5.0,
            endpoint: "/v1/ecommerce/quotes",
            requestBody: quote,
            responseType: QuotesResponse.self
        ) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    public func createEvents(_ event: EventsRequest, completion: @escaping @Sendable (Result<EventsResponse, NetworkError>) -> Void) {
        post(
            baseURL: logBaseURL,
            endpoint: "/v1/ecommerce/events",
            requestBody: event,
            responseType: EventsResponse.self
        ) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
}
