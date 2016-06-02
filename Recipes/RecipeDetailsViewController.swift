//
//  RecipeDetailsViewController.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

class RecipeDetailsViewController: UIViewController {

    init(recipe: Recipe) {
        super.init(nibName: "RecipeDetailsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}