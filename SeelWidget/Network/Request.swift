import Foundation

// MARK: - Network Request Error Types
public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int)
    case unknown
}

// MARK: - HTTP Method Enum
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Request Configuration Structure
struct RequestConfiguration {
    public var timeoutInterval: TimeInterval
    public var headers: [String: String]
    public var cachePolicy: URLRequest.CachePolicy
    
    init(
        timeoutInterval: TimeInterval = 30.0,
        headers: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) {
        self.timeoutInterval = timeoutInterval
        self.headers = headers
        self.cachePolicy = cachePolicy
    }
}

final class Request {
    
    // MARK: - Properties
    private let session: URLSession
    private var configuration: RequestConfiguration
    
    // MARK: - Initialization
    public init(configuration: RequestConfiguration = RequestConfiguration()) {
        self.configuration = configuration
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfig.timeoutIntervalForResource = configuration.timeoutInterval
        sessionConfig.requestCachePolicy = configuration.cachePolicy
        
        self.session = URLSession(configuration: sessionConfig)
    }
    
    // MARK: - Configuration Update Methods
    
    /// Update request configuration
    public func updateConfiguration(_ newConfiguration: RequestConfiguration) {
        self.configuration = newConfiguration
    }
    
    /// Add or update header information
    public func updateHeaders(_ headers: [String: String]) {
        for (key, value) in headers {
            configuration.headers[key] = value
        }
    }
    
    /// Remove header information
    public func removeHeader(_ key: String) {
        configuration.headers.removeValue(forKey: key)
    }
    
    // MARK: - Callback-based Network Request Methods
    
    /// Generic request method (callback-based)
    public func request<T: Codable>(
        url: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set default headers
        for (key, value) in configuration.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set custom headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Handle request parameters
        if let parameters = parameters {
            switch method {
            case .GET:
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    request.url = components.url
                }
            case .POST, .PUT, .PATCH:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    completion(.failure(.networkError(error)))
                    return
                }
            default:
                break
            }
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            // Check HTTP status code
            guard 200...299 ~= httpResponse.statusCode else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Parse response data
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Convenience Methods
    
    /// GET request
    public func get<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        request(
            url: url,
            method: .GET,
            parameters: parameters,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    /// POST request
    public func post<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        request(
            url: url,
            method: .POST,
            parameters: parameters,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    /// PUT request
    public func put<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        request(
            url: url,
            method: .PUT,
            parameters: parameters,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    /// DELETE request
    public func delete<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        request(
            url: url,
            method: .DELETE,
            parameters: parameters,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    /// Raw data request method
    public func requestData(
        url: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set default headers
        for (key, value) in configuration.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set custom headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Handle request parameters
        if let parameters = parameters {
            switch method {
            case .GET:
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    request.url = components.url
                }
            case .POST, .PUT, .PATCH:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    completion(.failure(.networkError(error)))
                    return
                }
            default:
                break
            }
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            // Check HTTP status code
            guard 200...299 ~= httpResponse.statusCode else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
}
