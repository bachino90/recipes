//
//  Row.swift
//  Recipes
//
//  Created by Restorando on 6/2/16.
//  Copyright © 2016 Restorando. All rights reserved.
//

import UIKit

protocol RowProtocol {

    var cellIdentifier: String { get }
    var cellHeight: CGFloat { get }
    func configureCell(cell: UIView)
    func performAction()
}

extension RowProtocol {
    func performAction() { }
}

class Row {

    var cellIdentifier: String { get { fatalError("notImplemented") } }

    var cellHeight: CGFloat { get { fatalError("notImplemented") } }

    func configureCell(cell: UIView) { fatalError("notImplemented") }

    func performAction() { fatalError("notImplemented") }
}