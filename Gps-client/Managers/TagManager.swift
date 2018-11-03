//
//  TagManager.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 11.04.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import CoreLocation
import UIKit

protocol TagManagerDelegate: class {
	func didUpdateTags(visibleBeacons: [Beacon])
	func didUpdateLocation(location: Location)
}

final class TagManager: NSObject {
	private let beaconService: BeaconService
	let rangingManager: TagRangingManagerProtocol
	weak var delegate: TagManagerDelegate?
	
	init(beaconService: BeaconService = BeaconNetworkService(),
		 rangingManager: TagRangingManagerProtocol = TagRangingManager()) {
		self.beaconService = beaconService
		self.rangingManager = rangingManager
		super.init()
	}
	
	func update(location: Location, for tag: Tag, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		self.beaconService.update(location: location, for: tag) { (success: Bool, error: Error?) in
			printd("Did send location")
			completion?(success, error)
		}
	}
	
	func update(location: CLLocation, major: Int, minor: Int, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		let tag: Tag = Tag(major: major, minor: minor)
		self.update(location: location.pawscoutLocation, for: tag, completion: completion)
	}
	
	func refreshLocationServices() {
		self.rangingManager.refreshLocationServices()
	}
	
	func startRangingBeacons() {
		self.rangingManager.delegate = self
		self.rangingManager.reset()
		self.rangingManager.refreshBeaconRanging()
		self.rangingManager.monitor(withUUID: "604a9672-4469-45fb-b94f-1bb9d75af49c", identifier: "PAWSCOUT-TAG", notifyOnEntry: true, notifyOnDisplay: true, notifyOnExit: true)
	}
	
	func stopMonitoring() {
		self.rangingManager.stopMonitoring()
	}
	
	func setUpdatingInterval(with value: TimeInterval) {
		self.rangingManager.sendingRequestInterval = value
	}
	
	func calculateDistance(with rssi: Int) -> Double {
		return Double(rssi * -1)
	}
}

extension TagManager: TagRangingManagerDelegate {
	//new beacons
	func rangingManager(_ manager: TagRangingManager, didDetectNewBeacons beacons: [Beacon]) {
		guard let deviceId: String = UIDevice.current.identifierForVendor?.uuidString else { fatalError("NO ID FOR VENDOR") }
		print("New beacons")
		self.delegate?.didUpdateTags(visibleBeacons: self.rangingManager.allBeacons)
		for beacon: Beacon in beacons {
			guard let location: Location = beacon.tag.location else { return }
			
			let beaconPayload: BeaconDetectedPayload = BeaconDetectedPayload(tagIdentifier: beacon.tag.identifier, deviceId: deviceId, location: location, signal: beacon.rssi)
			self.beaconService.didDetectBeacon(with: beaconPayload, completion: { (_: Bool, _: Error?) in
				printd("Did detect beacon", beacon.tag.identifier)
			})
		}
	}
	
	func rangingManager(_ manager: TagRangingManager, didRetrieve location: Location, for beacons: [Beacon]) {
		printd("Beacons to send location: ", beacons.count)
		self.delegate?.didUpdateTags(visibleBeacons: self.rangingManager.allBeacons)
		for beacon: Beacon in beacons {
			self.update(location: location, for: beacon.tag, completion: { (_: Bool, _: Error?) in
				printd("Location Updated")
			})
		}
	}
	
	func rangingManager(_ manager: TagRangingManager, didReportOutOfRangeBeacons beacons: [Beacon], with location: Location?) {
		self.delegate?.didUpdateTags(visibleBeacons: self.rangingManager.allBeacons)
		guard let location: Location = location else { return }
		for beacon: Beacon in beacons {
			printd("Removed beacon:", beacon.tag.identifier)
			self.update(location: location, for: beacon.tag, completion: { (_: Bool, _: Error?) in
				printd("Location Updated")
			})
		}
	}

	func rangingManager(_ manager: TagRangingManager, didUpdate location: Location) {
		self.delegate?.didUpdateLocation(location: location)
	}
}
