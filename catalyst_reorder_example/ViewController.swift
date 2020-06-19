//
//  ViewController.swift
//  catalyst_reorder_example
//
//  Created by John Davis on 11/13/19.
//  Copyright © 2019 John Davis. All rights reserved.
//

import UIKit

struct Cell {
    let uuid = UUID()
    let text: String
    
    init(text: String, uuid: UUID = UUID()) {
        self.text = text
    }
}

extension Cell: Hashable {
    
}

class ViewController: UIViewController {
    enum Section {
        case main
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var dataSource: TableDataSource?
    var cellData: [Cell] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let useDragAndDropReordering = true
        
        if useDragAndDropReordering {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
            tableView.dragInteractionEnabled = true
        } else {
            tableView.dragDelegate = nil
            tableView.dropDelegate = nil
            tableView.dragInteractionEnabled = false
        }
        
        setupDataSource()
        setupInitialCellData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        applySnapshotFromTrueData()
    }
    
    func setupDataSource() {
        dataSource = TableDataSource(tableView: tableView, cellProvider: { [weak self] tableView, path, identifier in
            guard let self = self else { return nil }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return nil }
            guard let model = self.cellData.first(where: { $0.uuid == identifier }) else { return nil}
            
            cell.textLabel?.text = model.text
            return cell
        })
    }
    
    func setupInitialCellData() {
        cellData = [Cell(text: "Cat"), Cell(text: "Dog"), Cell(text: "Eel")]
    }
    
    func applySnapshotFromTrueData(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cellData.map { return $0.uuid })
        dataSource?.apply(snapshot, animatingDifferences: animated)
    }

}

extension ViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print("ITEMS FOR BEGINNING")
        let item = cellData[indexPath.row]
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension ViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        print("Can Handle")
        return true
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let draggedItems = coordinator.session.localDragSession?.items else { return }
        guard let destinationPath = coordinator.destinationIndexPath else { return }
        let localObjects = draggedItems.compactMap { return $0.localObject as? Cell }

        var newItems = cellData.filter { cell in
            !localObjects.contains(where: { $0 == cell })
        }

        var insertIndex = destinationPath.row
        if insertIndex > newItems.count {
            insertIndex = newItems.count
        }

        localObjects.reversed().forEach { object in
            newItems.insert(object, at: insertIndex)
        }

        cellData = newItems
        applySnapshotFromTrueData(animated: false)
    }
}
