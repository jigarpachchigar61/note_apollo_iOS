//
//  CategoryViewCell.swift
//  note_apollo_iOS
//
//  Created by Nency on 01/02/21.
//

import Foundation
import UIKit

class CategoryViewCell: UITableViewCell {
    
    @IBOutlet weak var txtCategoryName: UITextField!
    
    func initCell(name: String){
        txtCategoryName.text = name
    }
}

