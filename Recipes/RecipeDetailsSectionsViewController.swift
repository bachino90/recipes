//
//  RecipeDetailsSectionsViewController.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class RecipeDetailsSectionsViewController: SectionsViewController {

    var recipe: Recipe

    init(recipe: Recipe) {
        self.recipe = recipe
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = recipe.name
        tableView.registerClass(IngredientsHeaderCell.self, forCellReuseIdentifier: "IngredientsHeaderCell")
        tableView.registerClass(IngredientCell.self, forCellReuseIdentifier: "IngredientCell")
        tableView.registerClass(DescriptionCell.self, forCellReuseIdentifier: "DescriptionCell")
        sections = [
            IngredientSection(ingredients: recipe.ingredients),
            DescriptionSection(description: recipe.description)
        ]
    }
}