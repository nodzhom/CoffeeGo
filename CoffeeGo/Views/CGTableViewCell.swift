//
//  CGTableViewCell.swift
//  CoffeeGo
//
//  Created by Onur Com on 8.05.2020.
//  Copyright © 2020 Onur Com. All rights reserved.
//

import UIKit
import SafariServices

protocol CGTableViewCellDelegate {
    func actionButtonTapped(at index: IndexPath)
}

class CGTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var capsuleView: UIView!
    
    var delegate: CGTableViewCellDelegate!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureViews() {
        capsuleView.layer.cornerRadius = 10
        actionButton.layer.cornerRadius = 10
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
         self.delegate?.actionButtonTapped(at: indexPath)
      
    }
    
}
