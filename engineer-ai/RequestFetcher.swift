//
//  RequestFetcher.swift
//  engineer-ai
//
//  Created by Vitalii Yevtushenko on 09.10.2019.
//  Copyright © 2019 ArcherSoft. All rights reserved.
//

import Foundation

protocol RequestFetcherDelegate: class {
    func requestFetcher(_ fetcher: RequestFetcher, didFetchHits hits: [Hit])
    func requestFetcher(_ fetcher: RequestFetcher, didFailWithError error: Error)
}

final class RequestFetcher {

    let page: Int
    let url: URL
    weak var delegate: RequestFetcherDelegate?

    init(page: Int, delegate: RequestFetcherDelegate) {
        // It is correct to use force unwrap here because url in this case could not be invalid
        url = URL(string: "https://hn.algolia.com/api/v1/search_by_date?tags=story&page=\(page)")!
        self.page = page
        self.delegate = delegate
    }

    func fetch() {
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let data = data {
                self?.processData(data)
            } else if let error = error {
                self?.processError(error)
            } else {
                print("Incorrect iOS SDK completion handler")
            }
        }
        task.resume()
    }

    private func processData(_ data: Data) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let hits = try decoder.decode(Hits.self, from: data)
            delegate?.requestFetcher(self, didFetchHits: hits.hits)
        } catch {
            processError(error)
        }
    }

    private func processError(_ error: Error) {
        delegate?.requestFetcher(self, didFailWithError: error)
    }
}
