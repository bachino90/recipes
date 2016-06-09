//
//  DescriptionSection.swift
//  Recipes
//
//  Created by Restorando on 6/9/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import Foundation

class DescriptionSection: Section {

    init(description: String) {
        super.init()
        rows = [DescriptionRow(description: description)]
    }
}