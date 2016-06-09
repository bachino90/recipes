//
//  DescriptionCell.swift
//  Recipes
//
//  Created by Restorando on 6/9/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class DescriptionRow: Row {

    var descriptionText: String

    init(description: String) {
        self.descriptionText = description
    }

    override var cellIdentifier: String { get { return "DescriptionCell" } }

    override var cellHeight: CGFloat { get { return DescriptionCell.cellHeight() } }

    override func configureCell(cell: UIView) {
        if let cell = cell as? DescriptionCell {
            cell.configureForDescription(descriptionText)
        }
    }
}

class DescriptionCell: UITableViewCell {

    class func cellHeight() -> CGFloat { return 50.0 }

    func configureForDescription(description: String) {
        textLabel?.text = description
    }
}
