//
//  DataLoader.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case unsupportedURL
    case network(Error?)
    case statusCodeError(Int)
    case noHTTPResponse
    case badData
    case queryTimeLimit
    case notModified // 304
    case badRequest //400
    case unAuthorized //401
    case forbidden //403
    case notFound //404
    case methodNotAllowed // 405
    case timeOut //408
    case unSupportedMediaType //415
    case validationFailed // 422
    case rateLimitted //429
    case serverError //500
    case serverUnavailable //503
    case gatewayTimeout //504
    case networkAuthenticationRequired //511
    case invalidImage
    case invalidMetadata
    case invalidToken
    case invalidURLRequest
    case invalidURL
    case unKnown
}

class DataLoader {
    typealias JSONTaskCompletionHandler = (Decodable?, NetworkError?) -> Void
    
    var decoder: JSONDecoder
    private let urlSession: URLSession
    private let oauthClient: OAuthClient
    private let authManager: AuthManager
    
    private var successCodes: CountableRange<Int> = 200..<299
    private var failureClientCodes: CountableRange<Int> = 400..<499
    private var failureBackendCodes: CountableRange<Int> = 500..<511
    
    enum EndPointType: String {
        case login
        case search
    }
    
    static let defaultHeaders = [
        "accept": "application/vnd.github.v3+json",
    ]
    
    internal static func buildHeaders(key: String, value: String) -> [String: String] {
        var headers = defaultHeaders
        headers[key] = value
        return headers
    }
    
    var showHeader: ((_ header: [String: String]) -> Void)?

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()
         , oauthClient: OAuthClient = RemoteOAuthClient()
         , authManager: AuthManager = AuthManager())
    {
        self.urlSession = session
        self.decoder = decoder
        self.oauthClient = oauthClient
        self.authManager = authManager
    }
}

// MARK: - Public
extension DataLoader {
    func fetch<T: Decodable>(_ endpoint: EndPoint, decode: @escaping (Decodable) -> T?) async throws -> Result<T, NetworkError> {
        try Task.checkCancellation()
        
        do {
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(Result<T, NetworkError>), Error>) in
                loadRequest(endpoint, decode: decode) { result in
                    switch result {
                        case .success(let data):
                            continuation.resume(returning: .success(data))
                        case .failure(let error):
                            continuation.resume(throwing: error)
                    }
                }
            })
        } catch NetworkError.unAuthorized  {
            return Result.failure(NetworkError.unAuthorized)
        } catch NetworkError.timeOut  {
            return Result.failure(NetworkError.timeOut)
        } catch NetworkError.invalidToken  {
            return Result.failure(NetworkError.invalidToken)
        } catch {
            print("fetchDataWithConcurrency error \(error)")
            return Result.failure(NetworkError.unKnown)
        }
    }
    
    func fetch<T: Decodable>(_ endpoint: URL, decode: @escaping (Decodable) -> T?) async throws -> Result<T, NetworkError> {
        try Task.checkCancellation()
        
        do {
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(Result<T, NetworkError>), Error>) in
                loadRequest(endpoint, decode: decode) { result in
                    switch result {
                        case .success(let data):
                            continuation.resume(returning: .success(data))
                        case .failure(let error):
                            continuation.resume(throwing: error)
                    }
                }
            })
        } catch NetworkError.unAuthorized  {
            return Result.failure(NetworkError.unAuthorized)
        } catch NetworkError.timeOut  {
            return Result.failure(NetworkError.timeOut)
        } catch NetworkError.invalidToken  {
            return Result.failure(NetworkError.invalidToken)
        } catch {
            print("fetchDataWithConcurrency error \(error)")
            return Result.failure(NetworkError.unKnown)
        }
    }
    
    func fetchToken<T: Decodable>(_ endpoint: LoginEndPoint, decode: @escaping (Decodable) -> T?) async throws -> Result<T, NetworkError> {
        try Task.checkCancellation()
        
        do {
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(Result<T, NetworkError>), Error>) in
                loadAuthorized(endpoint, decode: decode) { result in
                    switch result {
                        case .success(let data):
                            continuation.resume(returning: .success(data))
                        case .failure(let error):
                            continuation.resume(throwing: error)
                    }
                }
            })
        } catch NetworkError.unAuthorized  {
            
            return Result.failure(NetworkError.unAuthorized)
            
        } catch NetworkError.timeOut  {
            return Result.failure(NetworkError.timeOut)
        } catch {
            print("fetchDataWithConcurrency error \(error)")
            return Result.failure(NetworkError.unKnown)
        }
    }
   
    @available(iOS 15.0, *)
    func fetchUserInfo(_ metadataUrl: URL) async throws -> UsersInfo {
        let metadataRequest = URLRequest(url: metadataUrl)
        let (data, metadataResponse) = try await URLSession.shared.data(for: metadataRequest)
        guard (metadataResponse as? HTTPURLResponse)?.statusCode == 200 else {
            throw handleHTTPResponse(statusCode: (metadataResponse as? HTTPURLResponse)?.statusCode ?? 999)
        }
        
        return try self.decoder.decode(UsersInfo.self, from: data)
    }
    
    
    func refreshToken(withRefreshToken: String) async throws -> TokenResponse {
        
        let endPoint = LoginEndPoint.refreshToken(received: withRefreshToken)
        
        var returnData: TokenResponse!
        var getData: ((TokenResponse) -> Void)?
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = authorizedURLRequest(with: endPoint)
        
        guard let request = request else {
            throw NetworkError.invalidURLRequest
        }
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                if let error = error {
                    
                    let errorCode = (error as NSError).code
                    
                    switch errorCode {
                        case NSURLErrorTimedOut:
                            print("NSURLErrorTimedOut")
                        default:
                        print("error \(error)")
                    }
                    return
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            if self.successCodes.contains(httpResponse.statusCode) {
                guard let data = data else {
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    
                    let components = responseString.components(separatedBy: "&")
                    var dictionary: [String: String] = [:]
                    for component in components {
                        let itemComponents = component.components(separatedBy: "=")
                        if let key = itemComponents.first, let value = itemComponents.last {
                          dictionary[key] = value
                        }
                    }
                    
                    let expires_in = Double(dictionary["expires_in"] ?? "0")
                    let refresh_token_expires_in = Double(dictionary["refresh_token_expires_in"] ?? "0")
                    
                    let token = TokenResponse(access_token: dictionary["access_token"], expires_in: expires_in, refresh_token: dictionary["refresh_token"], refresh_token_expires_in: refresh_token_expires_in, scope: dictionary["scope"], token_type: dictionary["token_type"], isValid: true)
                    
                    getData?(token)

                }
                
            } else {
                let error = self.handleHTTPResponse(statusCode: httpResponse.statusCode)
                print("error \(error)")
                
                let token = TokenResponse(access_token: "", expires_in: 0, refresh_token: "", refresh_token_expires_in: 0, scope: "", token_type: "", isValid: false)
                
                getData?(token)
            }
        }
        task.resume()
        
        getData = { token in
            returnData = token
            semaphore.signal()
        }
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return returnData
    }
}

// MARK: - Base
extension DataLoader {
    
    @available(iOS 13.0.0, *)
    func loadRequest<T: Decodable>(_ endpoint: EndPoint, decode: @escaping (Decodable) -> T?, then handler: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let url = endpoint.url else {
            return
        }
        
        let request = searchURLRequest(with: url)
        
        guard let request = request else {
            handler(Result.failure(NetworkError.invalidURLRequest))
            return
        }
       
        let task = decodingTaskWithConcurrency(with: request, decodingType: T.self) { (json , error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        handler(Result.failure(error))
                    }
                    return
                }

                if let value = decode(json) {
                    handler(.success(value))
                }
            }
        }
        task.resume()
    }
    
    func loadRequest<T: Decodable>(_ endpoint: URL, decode: @escaping (Decodable) -> T?, then handler: @escaping (Result<T, NetworkError>) -> Void) {
        
        let request = searchURLRequest(with: endpoint)
        
        guard let request = request else {
            handler(Result.failure(NetworkError.invalidURLRequest))
            return
        }
       
        let task = decodingTaskWithConcurrency(with: request, decodingType: T.self) { (json , error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        handler(Result.failure(error))
                    }
                    return
                }

                if let value = decode(json) {
                    handler(.success(value))
                }
            }
        }
        task.resume()
    }
    
    func loadAuthorized<T: Decodable>(_ endPoint: LoginEndPoint, decode: @escaping (Decodable) -> T?, handler: @escaping (Result<T, NetworkError>) -> Void) {
     
        let request = authorizedURLRequest(with: endPoint)
        
        guard let request = request else {
            handler(.failure(NetworkError.invalidURLRequest))
            return
        }
        
        let task = decodingTaskWithConcurrency(with: request, decodingType: T.self) { (json , error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        handler(Result.failure(error))
                    }
                    return
                }

                if let value = decode(json) {
                    handler(.success(value))
                }
            }
            
        }
        task.resume()
    }
    
    @available(iOS 15.0.0, *)
    func loadAuthorized<T: Decodable>(_ url: URL, allowRetry: Bool = true, decode: @escaping (Decodable) -> T?) async throws -> T {
        
        let request = try await authorizedRequest(from: url)
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
    
        // check the http status code and refresh + retry if we received 401 Unauthorized
        if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if allowRetry {
                _ = try await authManager.refreshToken()
                return try await loadAuthorized(url, allowRetry: false, decode: { json -> T? in
                    guard let feedResult = json as? T else { return  nil }
                    return feedResult
                })
            }
            
            print("httpResponse.statusCode \(httpResponse.statusCode)")
    
            throw NetworkError.invalidToken
        }
    
        let decoder = JSONDecoder()
        let response = try decoder.decode(T.self, from: data)
    
        return response
    }
    
    func loadAuthorizedWithContinuation<T: Decodable>(_ url: URL, decode: @escaping (Decodable) -> T?, then handler: @escaping (Result<T?, NetworkError>) -> Void) {
        
        Task {
            let request = try await authorizedRequest(from: url)

            let task = urlSession.dataTask(with: request) { data, response, error in
                
                guard error == nil else {
                    if let error = error {
                        print("error \(error)")
                        return
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("error \(NetworkError.noHTTPResponse)")
                    return
                }
                
                if self.successCodes.contains(httpResponse.statusCode) {
                    
                    guard let data = data else {
                        print("error \(NetworkError.badData)")
                        return
                    }
                    
                    if T.self == TokenResponse.self, let responseString = String(data: data, encoding: .utf8) {
                        let components = responseString.components(separatedBy: "&")
                        var dictionary: [String: String] = [:]
                        for component in components {
                            let itemComponents = component.components(separatedBy: "=")
                            if let key = itemComponents.first, let value = itemComponents.last {
                              dictionary[key] = value
                            }
                        }
                        
                        let expires_in = Double(dictionary["expires_in"] ?? "0")
                        let refresh_token_expires_in = Double(dictionary["refresh_token_expires_in"] ?? "0")
                        
                        let token = TokenResponse(access_token: dictionary["access_token"], expires_in: expires_in, refresh_token: dictionary["refresh_token"], refresh_token_expires_in: refresh_token_expires_in, scope: dictionary["scope"], token_type: dictionary["token_type"], isValid: true)
                        
                        DataLoader.token = token
                        
                        handler(.success(token as? T))
                        return
                        
                    } else {
                        do {
                            let decodable = try self.decoder.decode(T.self, from: data)
                            handler(.success(decodable))
                            
                        } catch {
                            print("error \(NetworkError.network(error))")
                        }
                    }
                  
                } else if httpResponse.statusCode == 304 {
                    print("error \(NetworkError.notModified)")
                    handler(.failure(NetworkError.notModified))
                } else if httpResponse.statusCode == 401 {
                    
                    guard let url = request.url else {
                        handler(.failure(NetworkError.invalidURL))
                        return
                    }
                    
                    Task {
                        async let _ = try await self.authManager.refreshToken()
                        async let _ = self.oauthClient.refreshToken(session: self.urlSession, url: url, decodingType: T.self) { result, error in
                            if let error = error {
                                handler(.failure(error))
                                return
                            }
                            handler(.success(result as? T))
                        }
                    }
                    
                } else {
                    handler(.failure(self.handleHTTPResponse(statusCode: httpResponse.statusCode)))
                }
            }
            task.resume()
        }
    }
    
    func fetchWithContinuation<T: Decodable>(_ url: URL, decode: @escaping (Decodable) -> T?) async throws -> T {
        
        return try await withCheckedThrowingContinuation({ continuation in
            loadAuthorizedWithContinuation(url, decode: decode) { result in
                switch result {
                    case .success(let data):
                    
                        guard let data = data else {
                            continuation.resume(throwing: NetworkError.badData)
                            return
                        }
                    
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        })
    }
    
    @available(iOS 13.0.0, *)
    private func decodingTaskWithConcurrency<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                if let error = error {
                    
                    let errorCode = (error as NSError).code
                    
                    switch errorCode {
                        case NSURLErrorTimedOut:
                            completion(nil, NetworkError.timeOut)
                        default:
                            completion(nil, NetworkError.network(error))
                    }
                    return
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NetworkError.noHTTPResponse)
                return
            }
            
            self.serverResponeHeader(httpResponse: httpResponse)
            
            if self.successCodes.contains(httpResponse.statusCode) {
                
                guard let data = data else {
                    completion(nil, NetworkError.badData)
                    return
                }
                
                if T.self == TokenResponse.self, let responseString = String(data: data, encoding: .utf8) {
                    let components = responseString.components(separatedBy: "&")
                    var dictionary: [String: String] = [:]
                    for component in components {
                        let itemComponents = component.components(separatedBy: "=")
                        if let key = itemComponents.first, let value = itemComponents.last {
                          dictionary[key] = value
                        }
                    }

                    let expires_in = Double(dictionary["expires_in"] ?? "0")
                    let refresh_token_expires_in = Double(dictionary["refresh_token_expires_in"] ?? "0")
                    
                    let token = TokenResponse(access_token: dictionary["access_token"], expires_in: expires_in, refresh_token: dictionary["refresh_token"], refresh_token_expires_in: refresh_token_expires_in, scope: dictionary["scope"], token_type: dictionary["token_type"], isValid: true)
                    
                    DataLoader.token = token
                    
                    completion(token, nil)
                    return
                    
                } else {
                    do {
                        let genericModel = try self.decoder.decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        completion(nil, NetworkError.network(error))
                    }
                }
                
            } else if httpResponse.statusCode == 304 {
                completion(nil, NetworkError.notModified)
            } else if httpResponse.statusCode == 401 {
  
                guard let url = request.url else {
                    completion(nil, NetworkError.invalidURL)
                    return
                }
                
                Task {
                    async let _ = try await self.authManager.refreshToken()
                    async let _ = self.oauthClient.refreshToken(session: self.urlSession ,url: url, decodingType: decodingType) { result, error in
                        if let error = error {
                            completion(nil, error)
                            return
                        }
                        completion(result, nil)
                    }
                }
                
            } else {
                completion(nil, self.handleHTTPResponse(statusCode: httpResponse.statusCode))
            }
        }
        
        return task
    }
    
    @available(iOS 15.0, *)
    func decodingTaskWithConcurrencyData<T: Decodable>(endPoint: URL, decodingType: T.Type) async throws -> Decodable? {
        let request = URLRequest(url: endPoint)
        let (data, metadataResponse) = try await URLSession.shared.data(for: request)
        guard (metadataResponse as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.noHTTPResponse
        }

        return try self.decoder.decode(decodingType, from: data)
    }
}

extension DataLoader {
    private func handleHTTPResponse(statusCode: Int) -> NetworkError {
       
        if self.failureClientCodes.contains(statusCode) { //400..<499
            switch statusCode {
                case 401:
                    return NetworkError.unAuthorized
                case 403:
                    return NetworkError.forbidden
                case 404:
                    return NetworkError.notFound
                case 405:
                    return NetworkError.methodNotAllowed
                case 408:
                    return NetworkError.timeOut
                case 415:
                    return NetworkError.unSupportedMediaType
                case 422:
                    return NetworkError.validationFailed
                case 429:
                    return NetworkError.rateLimitted
                default:
                    return NetworkError.statusCodeError(statusCode)
            }
            
        } else if self.failureBackendCodes.contains(statusCode) { //500..<511
            switch statusCode {
                case 500:
                    return NetworkError.serverError
                case 503:
                    return NetworkError.serverUnavailable
                case 504:
                    return NetworkError.gatewayTimeout
                case 511:
                    return NetworkError.networkAuthenticationRequired
                default:
                    return NetworkError.statusCodeError(statusCode)
            }
        } else {
            
            if statusCode == 999 {
                return NetworkError.unKnown
            }
            
            // Server returned response with status code different than expected `successCodes`.
            let info = [
                NSLocalizedDescriptionKey: "Request failed with code \(statusCode)",
                NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoint mapping."
            ]
            let error = NSError(domain: "NetworkService", code: statusCode, userInfo: info)
            return NetworkError.network(error)
        }
    }
    
    func authorizedURLRequest(with endPoint: LoginEndPoint) -> URLRequest? {
        let url = endPoint.tokenUrl!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = endPoint.query?.data(using: .utf8)
        return request
    }
    
    func searchURLRequest(with endPoint: URL) -> URLRequest? {
        var request = URLRequest(url: endPoint, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        let headers = DataLoader.buildHeaders(key: "Authorization", value: "Bearer \(DataLoader.accessToken ?? "")")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
    
    private func authorizedRequest(from url: URL) async throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        let token = try await authManager.validToken()
        let headers = DataLoader.buildHeaders(key: "Authorization", value: "Bearer \(token)")
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }

    func serverResponeHeader(httpResponse: HTTPURLResponse) {
        if let header = httpResponse.allHeaderFields as? [String: String] {
            showHeader?(header)
        }
    }
    
    func serverResponeHeaderWithKey(httpResponse: HTTPURLResponse, targetKey: String) -> String? {
        if let targetStr = httpResponse.value(forHTTPHeaderField: targetKey) {
            return targetStr
        } else {
            return nil
        }
    }
}
