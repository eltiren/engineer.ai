//
//  ListViewControllerModel.swift
//  engineer-ai
//
//  Created by Vitalii Yevtushenko on 09.10.2019.
//  Copyright © 2019 ArcherSoft. All rights reserved.
//

import Foundation

protocol ListViewControllerModelDelegate: class {
    func listViewControllerModelDidLoadHits(_ model: ListViewControllerModel)
    func listViewControllerModel(_ model: ListViewControllerModel, didAddHitsAt indexPaths: [IndexPath])
    func listViewControllerModel(_ model: ListViewControllerModel, selectedItemsCountChanged count: Int)
    func listViewControllerModel(_ model: ListViewControllerModel, didFailWithError error: Error)
}

final class ListViewControllerModel {

    weak var delegate: ListViewControllerModelDelegate?

    var numberOfItems: Int { hits.count }

    var selectedItemsCount: Int { selectedItemIndicies.count }

    func item(at indexPath: IndexPath) -> Hit {
        // auto load
        if indexPath.row == hits.count - 1 {
            fetchNextPage()
        }

        return hits[indexPath.row]
    }

    func isItemSelected(at indexPath: IndexPath) -> Bool {
        return selectedItemIndicies.contains(item(at: indexPath).objectID)
    }

    func toggleItem(_ hit: Hit) {
        if selectedItemIndicies.contains(hit.objectID) {
            selectedItemIndicies.remove(hit.objectID)
        } else {
            selectedItemIndicies.insert(hit.objectID)
        }
    }

    private var selectedItemIndicies = Set<String>() {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.listViewControllerModel(self, selectedItemsCountChanged: self.selectedItemIndicies.count)
            }
        }
    }

    private var hits: [Hit] = []
    private var lastLoadedPage = 0
    private var isFetching = false
    private var fetchPagesQueue = [Int]()
    private var requestFetcher: RequestFetcher?

    init() {
        fetchNextPage()
    }

    func reload() {
        hits = []
        lastLoadedPage = 0
        isFetching = false
        fetchNextPage()
    }

    private func fetchNextPage() {
        lastLoadedPage += 1

        if isFetching {
            fetchPagesQueue.append(lastLoadedPage)
        } else {
            isFetching = true
            requestFetcher = RequestFetcher(page: lastLoadedPage, delegate: self)
            requestFetcher?.fetch()
        }
    }

    private func fetchFromQueue() {
        let page = fetchPagesQueue.removeFirst()
        requestFetcher = RequestFetcher(page: page, delegate: self)
        requestFetcher?.fetch()
    }
}

extension ListViewControllerModel: RequestFetcherDelegate {
    func requestFetcher(_ fetcher: RequestFetcher, didFetchHits hits: [Hit]) {
        if fetchPagesQueue.isEmpty {
            isFetching = false
        } else {
            fetchFromQueue()
        }

        let indexPaths = (self.hits.count ..< self.hits.count + hits.count).map { IndexPath(row: $0, section: 0) }
        DispatchQueue.main.async {
            if fetcher.page == 1 {
                self.hits = hits
                self.delegate?.listViewControllerModelDidLoadHits(self)
            } else {
                self.hits += hits
                self.delegate?.listViewControllerModel(self, didAddHitsAt: indexPaths)
            }
        }
    }

    func requestFetcher(_ fetcher: RequestFetcher, didFailWithError error: Error) {
        isFetching = false
        lastLoadedPage = fetcher.page - 1
        fetchPagesQueue = []
        delegate?.listViewControllerModel(self, didFailWithError: error)
    }
}
