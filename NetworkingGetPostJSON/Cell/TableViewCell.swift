//
//  TableViewCell.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 22.04.21.
//

import UIKit

class TableViewCell: UITableViewCell {
    // MARK: - Outlet
    @IBOutlet weak var courseImage: UIImageView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var numberOfLessons: UILabel!
    @IBOutlet weak var numberOfTests: UILabel!
}
