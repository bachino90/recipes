//
//  RecipeCell.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

struct Recipe {
    var name: String
    var ingredients: [Ingredient]
}

protocol RecipeActionDelegate: ActionDelegate {
    func actionDidRequestToOpenRecipe(recipe: Recipe)
}

class RecipeRow: Row {

    var recipe: Recipe

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    override var cellIdentifier: String { get { return "RecipeCell" } }

    override var cellHeight: CGFloat { get { return RecipeCell.cellHeight() } }

    override func configureCell(cell: UIView) {
        if let cell = cell as? RecipeCell {
            cell.configureForRecipe(recipe)
        }
    }

    override func performAction() {
        delegate?.actionDidRequestToOpenRecipe(recipe)
    }

    private var delegate: RecipeActionDelegate? {
        return actionDelegate as? RecipeActionDelegate
    }
}

class RecipeCell: UITableViewCell {

    class func cellHeight() -> CGFloat { return 50.0 }

    func configureForRecipe(recipe: Recipe) {
        textLabel?.text = recipe.name
    }
}