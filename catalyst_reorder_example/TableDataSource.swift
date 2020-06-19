//
//  TableDataSource.swift
//  catalyst_reorder_example
//
//  Created by John Davis on 11/13/19.
//  Copyright © 2019 John Davis. All rights reserved.
//

import UIKit

class TableDataSource: UITableViewDiffableDataSource<ViewController.Section, UUID> {
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
}
