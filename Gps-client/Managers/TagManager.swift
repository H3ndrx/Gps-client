//
//  TagManager.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 11.04.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import CoreLocation
import Foundation

final class TagManager: NSObject {
	let beaconService: BeaconService
	let petService: PetService
	let rangingManager: TagRangingManagerProtocol
	
	init(beaconService: BeaconService = BeaconNetworkService(),
		 petService: PetService = PetNetworkService(),
		 rangingManager: TagRangingManagerProtocol = TagRangingManager()) {
		self.beaconService = beaconService
		self.petService = petService
		self.rangingManager = rangingManager
		super.init()
		
		self.rangingManager.delegate = self
		self.rangingManager.reset()
		self.rangingManager.refreshBeaconRanging()
		self.rangingManager.monitor(withUUID: "604a9672-4469-45fb-b94f-1bb9d75af49c", identifier: "PAWSCOUT-TAG", notifyOnEntry: true, notifyOnDisplay: true, notifyOnExit: true)
	}
	
	func update(location: Location, for tag: Tag, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		self.petService.update(location: location, for: tag) { (success: Bool, error: Error?) in
			printd("Did send location")
			completion?(success, error)
		}
	}
	
	func update(location: CLLocation, major: Int, minor: Int, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		let tag: Tag = Tag(major: major, minor: minor)
		self.update(location: location.pawscoutLocation, for: tag, completion: completion)
	}
	
	@objc func refreshLocationServices() {
		self.rangingManager.refreshLocationServices()
	}
	
	@objc func stopMonitoring() {
		self.rangingManager.stopMonitoring()
	}
	
	@objc func clearInRange() {
//		self.coreDataManager.clearTagsInRange()
	}
}

extension TagManager: TagRangingManagerDelegate {
	//new beacons
	func rangingManager(_ manager: TagRangingManager, didDetectNewBeacons beacons: [Beacon]) {
		print("New beacons")
		for beacon: Beacon in beacons {
			guard let location: Location = beacon.tag.location else { return }
//			let beaconPayload: BeaconDetectedPayload = BeaconDetectedPayload(tagIdentifier: beacon.tag.identifier, deviceId: deviceId, location: location, signal: beacon.rssi)
//			self.coreDataManager.insert(location: location, for: beacon.tag)
//			self.coreDataManager.update(true, for: beacon.tag)
//			self.beaconService.didDetectBeacon(with: beaconPayload, completion: { (_: Bool, _: Error?) in
//				printd("Did detect beacon", beacon.tag.identifier)
//			})
		}
	}
	
	func rangingManager(_ manager: TagRangingManager, didRetrieve location: Location, for beacons: [Beacon]) {
		printd("Beacons to send location: ", beacons.count)
		for beacon: Beacon in beacons {
			self.update(location: location, for: beacon.tag, completion: { (_: Bool, _: Error?) in
				printd("Location Updated")
			})
		}
	}
	
	func rangingManager(_ manager: TagRangingManager, didReportOutOfRangeBeacons beacons: [Beacon], with location: Location?) {
		guard let location: Location = location else { return }
		for beacon: Beacon in beacons {
			printd("Removed beacon:", beacon.tag.identifier)
			self.update(location: location, for: beacon.tag, completion: { (_: Bool, _: Error?) in
				printd("Location Updated")
			})
		}
	}
}
