//
//  RemoteDataAsyncSequence.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/30.
//

import Foundation

@available(iOS 15.0, *)
struct RemoteDataAsyncSequence: AsyncSequence {
    typealias Element = UsersInfo

    var urls: [URL]
    var urlSession: URLSession

    func makeAsyncIterator() -> RemoteDataAsyncIterator {
        RemoteDataAsyncIterator(urls: urls, urlSession: urlSession)
    }
}

@available(iOS 15.0, *)
struct RemoteDataAsyncIterator: AsyncIteratorProtocol {
    var urls: [URL]
    var urlSession: URLSession
    fileprivate var index = 0

    
    mutating func next() async throws -> UsersInfo? {
        guard index < urls.count else {
            return nil
        }

        let url = urls[index]
        index += 1

        let dataLoader = DataLoader()
        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        do {
            let metadata = try await dataLoader.fetchUserInfo(url)
            return metadata
        } catch  {
            throw error
        }
    }
}