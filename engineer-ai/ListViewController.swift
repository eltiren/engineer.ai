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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(HitCell.self, forCellReuseIdentifier: "hit-cell")
        model.delegate = self
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
        tableView.deselectRow(at: indexPath, animated: true)
        let item = model.item(at: indexPath)
        model.toggleItem(item)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    private func updateTitle() {
        title = "Selected: \(model.selectedItemsCount)"
    }
}

extension ListViewController: ListViewControllerModelDelegate {
    func listViewControllerModel(_ model: ListViewControllerModel, didAddHitsAt indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
    }

    func listViewControllerModel(_ model: ListViewControllerModel, selectedItemsCountChanged count: Int) {
        updateTitle()
    }

    func listViewControllerModelDidLoadHits(_ model: ListViewControllerModel) {
        tableView.reloadData()
        updateTitle()
    }

    func listViewControllerModel(_ model: ListViewControllerModel, didFailWithError error: Error) {
        print(error)
    }
}

extension ListViewController: HitCellDelegate {
    func hitCellSelectionStateChanged(_ cell: HitCell) {
        guard let hit = cell.hit else { return }
        model.toggleItem(hit)
    }
}
