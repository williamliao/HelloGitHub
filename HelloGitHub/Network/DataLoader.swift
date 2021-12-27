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
}

class DataLoader {
    
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    @available(iOS 13.0.0, *)
    func request(_ endpoint: EndPoint,
                 then handler: @escaping (Result<Data, NetworkError>) -> Void) async throws {
        guard let url = endpoint.url else {
            return handler(.failure(NetworkError.unsupportedURL))
        }

        let task = urlSession.dataTask(with: url) {
            data, _, error in

            let result = data.map(Result.success) ??
                .failure(NetworkError.network(error))

            handler(result)
        }

        task.resume()
    }
}

//dataLoader.request(.search(matching: query)) { result in
    //...
//}
