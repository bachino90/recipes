//
//  IngredientCell.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

struct Ingredient {
    var name: String
}

class IngredientRow: Row {

    var ingredient: Ingredient

    init(ingredient: Ingredient) {
        self.ingredient = ingredient
    }

    override var cellIdentifier: String { get { return "IngredientCell" } }

    override var cellHeight: CGFloat { get { return IngredientCell.cellHeight() } }

    override func configureCell(cell: UIView) {
        if let cell = cell as? IngredientCell {
            cell.configureForIngredient(ingredient)
        }
    }
}

class IngredientCell: UITableViewCell {

    class func cellHeight() -> CGFloat { return 50.0 }

    func configureForIngredient(ingredient: Ingredient) {
        textLabel?.text = ingredient.name
    }
}


