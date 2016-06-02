//
//  RecipeSectionsViewController.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import Foundation

class RecipeSectionsViewController: SectionsViewController {

    var recipes = [Recipe(name: "Empanada", ingredients: []), Recipe(name: "Pastel de carne", ingredients: [])]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.registerClass(RecipesHeaderCell.self, forCellReuseIdentifier: "RecipesHeaderCell")

        sections = [RecipesSection(recipes: recipes)]
    }
}

extension RecipeSectionsViewController: RecipeActionDelegate {

    func actionDidRequestToOpenRecipe(recipe: Recipe) {
        let vc = RecipeDetailsViewController(recipe: recipe)
        navigationController?.pushViewController(vc, animated: true)
    }
}