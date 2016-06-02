//
//  RecipesSection.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class RecipesSection: Section {

    override var headerHeight: CGFloat { return RecipesHeaderCell.cellHeight() }

    override var headerCellIdentifier: String? { return "RecipesHeaderCell" }

    override func configureHeader(cell: UITableViewCell) {
        if let cell = cell as? RecipesHeaderCell {
            cell.configureForTitle("")
        }
    }

    init(recipes: [Recipe]) {
        super.init()
        rows = recipes.map { RecipeRow(recipe: $0) }
    }
}

class RecipesHeaderCell: UITableViewCell {

    class func cellHeight() -> CGFloat { return 50.0 }

    func configureForTitle(title: String) {
        textLabel?.text = title
    }
}