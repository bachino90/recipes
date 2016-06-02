//
//  SectionsViewController.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class SectionsViewController: UIViewController, ActionDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: — Public Interface

    @IBOutlet weak var tableView: UITableView!

    var sections = [Section]() {
        didSet {
            sections.map { $0.actionDelegate = self }
            reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func reloadData() { tableView.reloadData() }

    func rowForIndexPath(indexPath: NSIndexPath) -> Row {
        let section = sections[indexPath.section]
        return section.rows[indexPath.row]
    }

    func indexPathForRow(aRow: Row) -> NSIndexPath? {
        var sectionIndex = -1, rowIndex = -1
        for section in sections {
            sectionIndex += 1
            for row in section.rows {
                rowIndex += 1
                if row === aRow { return NSIndexPath(forRow: rowIndex, inSection: sectionIndex) }
            }
            rowIndex = -1
        }
        return nil
    }

    // MARK: — UITableViewDelegate & UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return sections.count }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        return section.rows.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = rowForIndexPath(indexPath)
        if let cell = tableView.dequeueReusableCellWithIdentifier(row.cellIdentifier) {
            row.configureCell(cell)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let row = rowForIndexPath(indexPath)
        return row.cellHeight
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]
        if let headerIdentifier = section.headerCellIdentifier {
            let cell = tableView.dequeueReusableCellWithIdentifier(headerIdentifier)!
            section.configureHeader(cell)
            return cell
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = sections[section]
        return section.headerHeight
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = rowForIndexPath(indexPath)
        row.performAction()
    }
}