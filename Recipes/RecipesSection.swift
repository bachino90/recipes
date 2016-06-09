//
//  RecipesSection.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class RecipesSection: Section {

    var type: RecipeType?

    override var headerHeight: CGFloat { return (type != nil) ? RecipesHeaderCell.cellHeight() : 0.01 }

    override var headerCellIdentifier: String? { return "RecipesHeaderCell" }

    override func configureHeader(cell: UITableViewCell) {
        if let cell = cell as? RecipesHeaderCell {
            cell.configureForType(type)
        }
    }

    init(recipes: [Recipe]) {
        if recipes.count > 0 { type = recipes.first!.type }
        super.init()
        rows = recipes.map { RecipeRow(recipe: $0) }
    }
}

class RecipesHeaderCell: UITableViewCell {

    class func cellHeight() -> CGFloat { return 50.0 }

    func configureForType(type: RecipeType?) {
        textLabel?.text = type?.rawValue
    }
}