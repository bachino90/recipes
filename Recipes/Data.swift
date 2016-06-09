//
//  Data.swift
//  Recipes
//
//  Created by Restorando on 6/9/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import Foundation

struct Data {

    static let recipes = [
        Recipe(type: .Lunch, name: "Empanada", description: "Prueba", ingredients: [harina, harina]),
        Recipe(type: .Dinner, name: "Pastel de carne", description: "Prueba Prueba", ingredients: [harina])
    ]

    static var harina = Ingredient(name: "Harina")

}