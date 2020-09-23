//
//  NodeTableViewCell.swift
//  DataBaseTreeDemostration
//
//  Created by  Macbook on 22.09.2020.
//  Copyright © 2020 Golovelv Maxim. All rights reserved.
//

import UIKit

class NodeTableViewCell: UITableViewCell {

    @IBOutlet weak var valueButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
