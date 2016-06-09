//
//  RecipeDetailsTableViewController.swift
//  Recipes
//
//  Created by Restorando on 6/9/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class RecipeDetailsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var recipe: Recipe

    @IBOutlet weak var tableView: UITableView!

    init(recipe: Recipe) {
        self.recipe = recipe
        super.init(nibName: "RecipeDetailsTableViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = recipe.name
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    // MARK: — UITableViewDelegate & UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 2 }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return recipe.ingredients.count }
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("IngredientCell") as! IngredientCell
            cell.configureForIngredient(recipe.ingredients[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell") as! DescriptionCell
            cell.configureForDescription(recipe.description)
            return cell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 { return IngredientCell.cellHeight() }
        return DescriptionCell.cellHeight()
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return tableView.dequeueReusableCellWithIdentifier("IngredientsHeaderCell") as! IngredientsHeaderCell
        }
        return nil
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return IngredientsHeaderCell.cellHeight() }
        return 0.01
    }
}