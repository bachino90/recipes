//
//  IngredientSection.swift
//  Recipes
//
//  Created by Restorando on 6/9/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class IngredientSection: Section {

    override var headerHeight: CGFloat { return IngredientsHeaderCell.cellHeight() }

    override var headerCellIdentifier: String? { return "IngredientsHeaderCell" }

    init(ingredients: [Ingredient]) {
        super.init()
        rows = ingredients.map { IngredientRow(ingredient: $0) }
    }
}

class IngredientsHeaderCell: UITableViewCell {

    class func cellHeight() -> CGFloat { return 50.0 }

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.text = "Ingredients"
    }
}