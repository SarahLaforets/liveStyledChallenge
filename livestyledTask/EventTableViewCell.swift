//
//  EventTableViewCell.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import UIKit

protocol FavouriteStateChanging: class {
    func didPressButton(with cell: EventTableViewCell)
}

class EventTableViewCell: UITableViewCell {

    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var favouriteButton: UIButton!
    
    weak var cellDelegate: FavouriteStateChanging?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didPressFavouriteButton(_ sender: Any) {
        cellDelegate?.didPressButton(with: self)
    }
    
}
