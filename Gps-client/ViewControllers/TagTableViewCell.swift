//
//  TagTableViewCell.swift
//  Gps-client
//
//  Created by Gabriel Zolnierczuk on 03/11/2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import UIKit

final class TagTableViewCell: UITableViewCell {
	static let reuseIdentifier: String = "TagTableViewCell"
	@IBOutlet weak var signalStrengthLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

	func update(with signal: Int, distance: Double) {
		self.signalStrengthLabel.text = "Siła sygnału: \(signal)"
		self.distanceLabel.text = "Dystans: \(distance)m"
	}
	
}
