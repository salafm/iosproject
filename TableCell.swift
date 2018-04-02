//
//  TableCell.swift
//  Semargres
//
//  Created by NGI-1 on 3/16/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit

class TableCell: UITableViewCell {
    


    @IBOutlet weak var picWidth: NSLayoutConstraint!
    @IBOutlet weak var topLabel: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var frameList: UIView!
    @IBOutlet weak var pic: UIImageView!
}
