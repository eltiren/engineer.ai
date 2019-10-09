//
//  ViewController.swift
//  engineer-ai
//
//  Created by Vitalii Yevtushenko on 08.10.2019.
//  Copyright © 2019 ArcherSoft. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    private let model = ListViewControllerModel()
    private let listRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(HitCell.self, forCellReuseIdentifier: "hit-cell")
        tableView.allowsMultipleSelection = true

        model.delegate = self

        listRefreshControl.addTarget(self, action: #selector(ListViewController.refresh), for: .valueChanged)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = listRefreshControl
        } else {
            tableView.addSubview(listRefreshControl)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.numberOfItems
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "hit-cell", for: indexPath) as! HitCell
        cell.setup(hit: item, isSelected: model.isItemSelected(at: indexPath))
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model.item(at: indexPath)
        model.toggleItem(item)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let item = model.item(at: indexPath)
        model.toggleItem(item)
    }

    @objc func refresh() {
        model.reload()
    }

    private func updateTitle() {
        title = "Selected: \(model.selectedItemsCount)"
    }
}

extension ListViewController: ListViewControllerModelDelegate {
    func listViewControllerModel(_ model: ListViewControllerModel, didAddHitsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: .fade)
            self.tableView.endUpdates()
        }
    }

    func listViewControllerModel(_ model: ListViewControllerModel, selectedItemsCountChanged count: Int) {
        DispatchQueue.main.async {
            self.updateTitle()
        }
    }

    func listViewControllerModelDidLoadHits(_ model: ListViewControllerModel) {
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.updateTitle()
        }
    }

    func listViewControllerModel(_ model: ListViewControllerModel, didFailWithError error: Error) {
        print(error)
    }
}

extension ListViewController: HitCellDelegate {
    func hitCellSelectionStateChanged(_ cell: HitCell) {
        guard let hit = cell.hit, let indexPath = tableView.indexPath(for: cell) else { return }
        if model.isItemSelected(at: indexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        model.toggleItem(hit)
    }
}
