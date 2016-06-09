//
//  RecipeViewController.swift
//  Recipes
//
//  Created by Restorando on 6/9/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class RecipeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var recipes: [[Recipe]] = [[]] { didSet { tableView.reloadData() } }

    init() { super.init(nibName: "RecipeTableViewController", bundle: nil) }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes"

        tableView.registerClass(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.registerClass(RecipesHeaderCell.self, forCellReuseIdentifier: "RecipesHeaderCell")
        tableView.delegate = self
        tableView.dataSource = self

        recipes = [Data.recipes]
    }

    // MARK: — UITableViewDelegate & UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return recipes.count }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = recipes[section]
        return section.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = recipes[indexPath.section]
        let recipe = section[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell") as! RecipeCell
        cell.configureForRecipe(recipe)
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return RecipeCell.cellHeight()
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = recipes[section]
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipesHeaderCell") as! RecipesHeaderCell
        cell.configureForType(section.first!.type)
        return cell
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return RecipesHeaderCell.cellHeight()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let section = recipes[indexPath.section]
        let recipe = section[indexPath.row]
        let vc = RecipeDetailsTableViewController(recipe: recipe)
        navigationController?.pushViewController(vc, animated: true)
    }

}