//
//  HistoryTableViewCell.swift
//  Speedo
//
//  Created by Mushfiq Humayoon on 18/04/21.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    @IBOutlet weak var rideStartedFromLabel: UILabel!
    @IBOutlet weak var rideEndedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
