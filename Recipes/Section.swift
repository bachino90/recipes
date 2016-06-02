//
//  Section.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class Section {

    // MARK: - Rows

    var rows = [Row]()

    // MARK: - Header

    var headerHeight: CGFloat { return 0.01 }

    var headerCellIdentifier: String? { return nil }

    func configureHeader(cell: UITableViewCell) { }
    
}