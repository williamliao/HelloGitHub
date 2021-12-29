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
    case unKnown
}

class DataLoader {
    typealias JSONTaskCompletionHandler = (Decodable?, NetworkError?) -> Void
    
    var decoder: JSONDecoder
    
    private let urlSession: URLSession
    private var successCodes: CountableRange<Int> = 200..<299
    private var failureClientCodes: CountableRange<Int> = 400..<499
    private var failureBackendCodes: CountableRange<Int> = 500..<511

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.urlSession = session
        self.decoder = decoder
    }
}

// MARK: - Public
extension DataLoader {
    func fetch<T: Decodable>(_ endpoint: EndPoint, decode: @escaping (Decodable) -> T?) async throws -> Result<T, NetworkError> {
        try Task.checkCancellation()
        
        do {
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(Result<T, NetworkError>), Error>) in
                request(endpoint, decode: decode) { result in
                    continuation.resume(returning: result)
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
    
    func fetch<T: Decodable>(_ endpoint: URL, decode: @escaping (Decodable) -> T?) async throws -> Result<T, NetworkError> {
        try Task.checkCancellation()
        
        do {
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(Result<T, NetworkError>), Error>) in
                request(endpoint, decode: decode) { result in
                    continuation.resume(returning: result)
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
            throw NetworkError.invalidMetadata
        }
        
        return try self.decoder.decode(UsersInfo.self, from: data)
    }
}

// MARK: - Base
extension DataLoader {
    
    @available(iOS 13.0.0, *)
    func request<T: Decodable>(_ endpoint: EndPoint, decode: @escaping (Decodable) -> T?, then handler: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let url = endpoint.url else {
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
       
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
    
    func request<T: Decodable>(_ endpoint: URL, decode: @escaping (Decodable) -> T?, then handler: @escaping (Result<T, NetworkError>) -> Void) {
        
        let request = URLRequest(url: endpoint, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
       
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
            
            if self.successCodes.contains(httpResponse.statusCode) {
                
                guard let data = data else {
                    completion(nil, NetworkError.badData)
                    return
                }
                
                do {
                    let genericModel = try self.decoder.decode(decodingType, from: data)
                    completion(genericModel, nil)
                } catch {
                    completion(nil, NetworkError.network(error))
                }
                
            } else if httpResponse.statusCode == 304 {
                completion(nil, NetworkError.notModified)
            }  else {
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
    
    func decodingTaskWithConcurrency<T: Decodable>(endPoint: URL, decodingType: T.Type) async throws -> Decodable? {
        
        var returnData: Data?
        
        let task = urlSession.dataTask(with: endPoint) { data, response, error in
            
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
                returnData = data
                
            } else if httpResponse.statusCode == 304 {
                print("notModified")
            }  else {
                let error = self.handleHTTPResponse(statusCode: httpResponse.statusCode)
                print("error \(error)")
            }
        }
        task.resume()
        
        guard let data = returnData else {
            return nil
        }
        
        do {
            let genericModel = try self.decoder.decode(decodingType, from: data)
            return genericModel
        } catch {
            print("error \(error)")
            return nil
        }
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
            // Server returned response with status code different than expected `successCodes`.
            let info = [
                NSLocalizedDescriptionKey: "Request failed with code \(statusCode)",
                NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoint mapping."
            ]
            let error = NSError(domain: "NetworkService", code: statusCode, userInfo: info)
            return NetworkError.network(error)
        }
    }
}
