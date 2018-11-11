//
//  MainViewController.swift
//  Gps-client
//
//  Created by Gabriel Zolnierczuk on 13.05.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var intervalSlider: UISlider!
	@IBOutlet weak var intervalLabel: UILabel!
	
	private var isRanging: Bool = false
	private var currentLocation: Location?
	let tagManager: TagManager = Toybox.shared.tagManager
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tagManager.delegate = self
		self.tableView.dataSource = self
		self.statusLabel.text = String.empty
		self.intervalSlider.addTarget(self, action: #selector(self.didChangeSliderValue), for: .valueChanged)
		self.intervalSlider.setValue(5.0, animated: false)
	}
	
	@objc private func didChangeSliderValue(sender: UISlider) {
		let roundedValue: Float = sender.value.rounded(.down)
		sender.setValue(roundedValue, animated: true)
		self.tagManager.setUpdatingInterval(with: TimeInterval(60.0/roundedValue))
		self.updateIntervalLabel(with: Int(roundedValue))
	}
	
	@IBAction func didTapStartButton(_ sender: Any) {		
		guard !self.isRanging else {
			self.isRanging = false
			self.tagManager.stopMonitoring()
			self.startStopButton.setTitle("Start", for: .normal)
			return
		}
		self.tagManager.startRangingBeacons()
		self.tagManager.rangingManager.requestAlwaysPermissions(with: { (granted: Bool) in
			if granted {
				self.isRanging = true
				self.statusLabel.text = "Wyszukiwanie tagów w toku"
				self.tagManager.refreshLocationServices()
				self.startStopButton.setTitle("Stop", for: .normal)
			}
		})
	}
	
	private func updateIntervalLabel(with interval: Int) {
		if interval == 1 {
			self.intervalLabel.text = "\(interval) raz na minutę."
		} else {
			self.intervalLabel.text = "\(interval) razy na minutę."
		}
	}
}

extension MainViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tagManager.rangingManager.allBeacons.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell: TagTableViewCell = tableView.dequeueReusableCell(withIdentifier: TagTableViewCell.reuseIdentifier) as? TagTableViewCell else {
			return UITableViewCell()
		}
		let beacon: Beacon = self.tagManager.rangingManager.allBeacons[indexPath.row]
		cell.update(with: beacon.rssi, distance: self.tagManager.calculateDistance(with: beacon.rssi))
		return cell
	}
}

extension MainViewController: TagManagerDelegate {
	func didUpdateTags(visibleBeacons: [Beacon]) {
		self.tableView.reloadData()
	}
	
	func didUpdateLocation(location: Location) {
		self.currentLocation = location
		self.locationLabel.text = "\(location.latitude);\n\(location.longitude)"
	}
}
