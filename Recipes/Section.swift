//
//  Section.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

protocol SectionProtocol {
    var row: [Row] { get set }
    var headerHeight: CGFloat { get }
    var headerCellIdentifier: String? { get }
    func configureHeader(cell: UITableViewCell)
}

extension SectionProtocol {

    var headerHeight: CGFloat { return 0.01 }

    var headerCellIdentifier: String? { return nil }

    func configureHeader(cell: UITableViewCell) { }
}

class Section {

    weak var actionDelegate: ActionDelegate? {
        didSet { for row in rows { row.actionDelegate = self.actionDelegate } }
    }

    // MARK: - Rows

    var rows = [Row]()

    // MARK: - Header

    var headerHeight: CGFloat? { return nil }

    var headerCellIdentifier: String? { return nil }

    func configureHeader(cell: UITableViewCell) { }
    
}