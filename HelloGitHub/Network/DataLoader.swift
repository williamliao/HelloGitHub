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
}

class DataLoader {
    
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.urlSession = session
        self.decoder = decoder
    }
    
    @available(iOS 13.0.0, *)
    func request(_ endpoint: EndPoint,
                 then handler: @escaping (Result<Repositories, NetworkError>) -> Void) {
        
        guard let url = endpoint.url else {
            return handler(.failure(NetworkError.unsupportedURL))
        }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            
            
            guard error == nil else {
                if let error = error {
                    handler(Result.failure(NetworkError.network(error)))
                    return
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                handler(Result.failure(NetworkError.noHTTPResponse))
                return
            }
            
            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    handler(Result.failure(NetworkError.badData))
                    return
                }
                
                self.decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let repo = try self.decoder.decode(Repositories.self, from: data)
                   
                    if repo.incomplete_results {
                        handler(Result.failure(NetworkError.queryTimeLimit))
                    } else {
                        handler(Result.success(repo))
                    }
                    
                } catch {
                    handler(Result.failure(NetworkError.network(error)))
                }
            } else {
                handler(Result.failure(NetworkError.statusCodeError(httpResponse.statusCode)))
            }
        }

        task.resume()
    }
}
