//
//  TagRangingManager.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 30.01.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import CoreLocation
import UIKit

protocol TagRangingManagerDelegate: class {
	func rangingManager(_ manager: TagRangingManager, didRangeBeacons beacons: [Beacon]) //called all the time
	func rangingManager(_ manager: TagRangingManager, didDetectNewBeacons beacons: [Beacon]) //called only when beacons enters range
	func rangingManager(_ manager: TagRangingManager, didRetrieve location: Location, for beacons: [Beacon]) // called when location update is needed
	func rangingManager(_ manager: TagRangingManager, didReportOutOfRangeBeacons beacons: [Beacon], with location: Location?)
	func rangingManager(_ manager: TagRangingManager, didUpdate location: Location)
}

protocol TagRangingManagerProtocol: class {
	var delegate: TagRangingManagerDelegate? { get set }
	var sendingRequestInterval: TimeInterval { get set }
	var allBeacons: [Beacon] { get }
	func requestAlwaysPermissions(with completion: ((_ granted: Bool) -> Void)?)
	func reset()
	func refreshBeaconRanging()
	func refreshLocationServices()
	func monitor(withUUID uuidString: String, identifier: String, notifyOnEntry: Bool, notifyOnDisplay: Bool, notifyOnExit: Bool)
	func stopMonitoring()
}

final class TagRangingManager: NSObject, TagRangingManagerProtocol {
	static private let timeout: TimeInterval = 30.0
	static private let minLocationChangeForReport: Double = 50.0
	private var permissionCompletion: ((_ granted: Bool) -> Void)?
	
	// MARK: - Public
	weak var delegate: TagRangingManagerDelegate?
	var sendingRequestInterval: TimeInterval = 5.0
	var visibleBeacons: [UUID: [Beacon]] = [:]
	var atKnownLocation: Bool = false
	private var beaconReportedLocation: [String: CLLocation] = [:]
	var allBeacons: [Beacon] {
		var beacons: [Beacon] = []
		let chunks: [[Beacon]] = Array(self.visibleBeacons.values)
		for chunk: [Beacon] in chunks {
			beacons.append(contentsOf: chunk)
		}
		return beacons
	}
	
	// MARK: - Privates
	
	public private(set) var locationManager: CLLocationManagerWrapper?
	public private(set) var beaconsVisibleTimes: [String: TimeInterval] = [:]
	public private(set) var monitoredRegions: Set<CLBeaconRegion> = []
	
	init(locationManager: CLLocationManagerWrapper = CLLocationManager()) {
		self.locationManager = locationManager
		super.init()
		self.configureLocationManager()
	}
	
	// MARK: - Functions
	
	func requestAlwaysPermissions(with completion: ((_ granted: Bool) -> Void)?) {
		if self.locationManager?.authorizationStatus == .authorizedAlways {
			completion?(true)
		} else {
			self.locationManager?.requestAlwaysAuthorization()
			self.permissionCompletion = completion
		}
	}
	
	func reset() {
		self.reset(locationManager: CLLocationManager())
	}
	
	func reset(locationManager: CLLocationManagerWrapper) {
		if self.locationManager == nil {
			self.locationManager = locationManager
			self.configureLocationManager()
		}
		self.visibleBeacons = [:]
		self.beaconsVisibleTimes = [:]
	}
	
	func refreshBeaconRanging() {
		self.locationManager?.startUpdatingLocation()
		self.locationManager?.startMonitoringVisits()
		self.locationManager?.allowsBackgroundLocationUpdates = true
	}
	
	func monitor(withUUID uuidString: String, identifier: String, notifyOnEntry: Bool, notifyOnDisplay: Bool, notifyOnExit: Bool) {
		guard let uuid: UUID = UUID(uuidString: uuidString) else { return }
		let currentRegion: CLRegion? = self.locationManager?.monitoredRegions.first(where: {(region: CLRegion) -> Bool in
			return region.identifier == identifier
		})
		
		if let currentRegion: CLRegion = currentRegion {
			self.locationManager?.stopMonitoring(for: currentRegion)
		}
		
		let region: CLBeaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
		region.notifyEntryStateOnDisplay = notifyOnDisplay
		region.notifyOnEntry = notifyOnEntry
		region.notifyOnExit = notifyOnExit
		self.monitoredRegions.insert(region)
		self.locationManager?.startMonitoring(for: region)
	}
	
	@objc func stopMonitoring() {
		guard let monitoredRegions: Set<CLRegion> = self.locationManager?.monitoredRegions else { return }
		for region: CLRegion in monitoredRegions {
			if let beaconReg: CLBeaconRegion = region as? CLBeaconRegion {
				self.locationManager?.stopRangingBeacons(in: beaconReg)
			}
			self.locationManager?.stopMonitoring(for: region)
		}
		self.locationManager?.stopUpdatingLocation()
		self.locationManager = nil
		self.monitoredRegions = []
	}
	
	@objc func refreshLocationServices() {
		let energySaveModeDisabled: Bool = false
		let leashEnabled: Bool = false
		let walkEnabled: Bool = false
		
		self.refreshLocationServices(energySaveModeDisabled: energySaveModeDisabled, leashEnabled: leashEnabled, walkEnabled: walkEnabled, atKnownLocation: self.atKnownLocation)
	}
	
	func refreshLocationServices(energySaveModeDisabled: Bool, leashEnabled: Bool, walkEnabled: Bool, atKnownLocation: Bool) {
		if #available(iOS 11.0, *) {
			self.locationManager?.showsBackgroundLocationIndicator = leashEnabled || walkEnabled
		}
		
		if self.locationManager?.authorizationStatus == .authorizedWhenInUse {
			self.locationManager?.stopUpdatingLocation()
			return
		}
		
		if (leashEnabled || walkEnabled) || (!atKnownLocation && energySaveModeDisabled) {
			self.refreshBeaconRanging()
		} else {
			self.locationManager?.stopUpdatingLocation()
		}
	}
	
	// MARK: - Private functions
	
	private func configureLocationManager() {
		self.locationManager?.delegate = self
		self.locationManager?.distanceFilter = 1.0
		self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager?.pausesLocationUpdatesAutomatically = false
		self.locationManager?.allowsBackgroundLocationUpdates = true
		self.locationManager?.startMonitoringVisits()
	}
}

extension TagRangingManager: CLLocationManagerDelegate {
	// MARK: - Regions
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let beaconRegion: CLBeaconRegion = region as? CLBeaconRegion else { return }
		self.didEnterRegion(region: beaconRegion)
	}
	
	func didEnterRegion(region: CLBeaconRegion) {
		self.locationManager?.startRangingBeacons(in: region)
		self.refreshLocationServices()
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let beaconRegion: CLBeaconRegion = region as? CLBeaconRegion else { return }
		self.didExitRegion(region: beaconRegion)
	}
	
	func didExitRegion(region: CLBeaconRegion) {
		self.locationManager?.stopRangingBeacons(in: region)
		self.refreshLocationServices()
	}
	
	func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
		self.didVisit(visit: visit)
	}
	
	func didVisit(visit: CLVisit) {
		if visit.departureDate == Date.distantFuture {
			self.atKnownLocation = true
		} else {
			self.atKnownLocation = false
		}
		self.refreshLocationServices()
	}
	
	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		guard let beaconRegion: CLBeaconRegion = region as? CLBeaconRegion else { return }
		self.didStartMonitoring(for: beaconRegion)
	}
	
	func didStartMonitoring(for region: CLBeaconRegion) {
		self.locationManager?.startRangingBeacons(in: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		guard let beaconRegion: CLBeaconRegion = region as? CLBeaconRegion else { return }
		self.didDetermineState(state: state, for: beaconRegion)
	}
	
	func didDetermineState(state: CLRegionState, for region: CLBeaconRegion) {
		switch state {
		case .inside:
			self.locationManager?.startRangingBeacons(in: region)
		case .outside:
			self.locationManager?.stopRangingBeacons(in: region)
		default:
			return
		}
	}
	
	// MARK: - Ranging beacons
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		self.didRangeBeacons(beacons: beacons, in: region)
	}
	
	func didRangeBeacons(beacons: [CLBeacon], in region: CLBeaconRegion) {
		guard let locationManager: CLLocationManagerWrapper = self.locationManager else { return }
		if !locationManager.rangedRegions.contains(region) {
			return
		}
		var beaconsInRegion: [Beacon] = self.visibleBeacons[region.proximityUUID] ?? []
		var sameBeacons: Bool = true
		self.addNewBeacons(from: beacons, currentBeacons: &beaconsInRegion, sameBeacons: &sameBeacons)
		
		self.visibleBeacons[region.proximityUUID] = beaconsInRegion
		
		if !sameBeacons {
			self.removeSwapedBeacons(for: region, foundBeacons: beacons)
		}
		
		self.removeObsoleteBeacons(from: &self.visibleBeacons)
		
		self.updateBeacons(from: beacons)
		self.delegate?.rangingManager(self, didRangeBeacons: self.allBeacons)
		self.reportLocation(for: self.allBeacons)
	}
	
	func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
		self.rangingBeaconsDidFailFor(region: region, withError: error)
	}
	
	func rangingBeaconsDidFailFor(region: CLBeaconRegion, withError error: Error) {
		self.locationManager?.stopRangingBeacons(in: region)
		self.delegate?.rangingManager(self, didReportOutOfRangeBeacons: self.visibleBeacons[region.proximityUUID] ?? [], with: self.locationManager?.location?.pawscoutLocation)
		self.visibleBeacons[region.proximityUUID] = []
		self.beaconsVisibleTimes = [:]
	}
	
	// MARK: - Status
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		guard let locationManager: CLLocationManagerWrapper = self.locationManager else { return }
		if self.permissionCompletion != nil {
			self.permissionCompletion?(status == .authorizedAlways)
			self.permissionCompletion = nil
			return
		}
		if locationManager.canRetrieveLocation {
			self.continueMonitoring()
		} else {
			self.delegate?.rangingManager(self, didReportOutOfRangeBeacons: self.allBeacons, with: self.locationManager?.location?.pawscoutLocation)
			self.reset()
		}
		self.refreshLocationServices()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location: CLLocation = locations.last else { return }
		self.delegate?.rangingManager(self, didUpdate: location.pawscoutLocation)
	}
	
	// MARK: - Privates
	
	private func continueMonitoring() {
		for region: CLBeaconRegion in self.monitoredRegions {
			self.locationManager?.startMonitoring(for: region)
		}
	}
	
	//add new beacons for caching
	private func addNewBeacons(from beacons: [CLBeacon], currentBeacons beaconsInRegion: inout [Beacon], sameBeacons: inout Bool) {
		var addedBeacons: [Beacon] = []
		for beacon: CLBeacon in beacons {
			let containsBeacon: Bool = beaconsInRegion.contains(where: { (enumeratedBeacon: Beacon) -> Bool in
				return enumeratedBeacon.tag.identifier.major == beacon.major.intValue && enumeratedBeacon.tag.identifier.minor == beacon.minor.intValue
			})
			guard let proximity: Proximity = Proximity(rawValue: beacon.proximity.rawValue) else {
				fatalError("Wrong proximity value")
			}
			let tag: Tag = Tag(major: beacon.major.intValue, minor: beacon.minor.intValue, location: self.locationManager?.location?.pawscoutLocation)
			let newBeacon: Beacon = Beacon(tag: tag, proximityUUID: beacon.proximityUUID, rssi: beacon.rssi, proximity: proximity)
			if newBeacon.proximity != .unknown {
				if !containsBeacon {
					addedBeacons.append(newBeacon)
					beaconsInRegion.append(newBeacon)
					sameBeacons = false
				}
				self.beaconsVisibleTimes[newBeacon.tag.identifier.id] = Date().timeIntervalSince1970
			}
		}
		if !addedBeacons.isEmpty {
			self.delegate?.rangingManager(self, didDetectNewBeacons: addedBeacons)
		}
	}
	
	// removes beacons which can be added in different regions because of low battery uuid change
	private func removeSwapedBeacons(for region: CLBeaconRegion, foundBeacons: [CLBeacon]) {
		for beacon: CLBeacon in foundBeacons {
			for (key, beacons) in self.visibleBeacons where key != region.proximityUUID {
				let beaconToRemove: Beacon? = beacons.first(where: { (enumeratedBeacon: Beacon) -> Bool in
					return enumeratedBeacon.tag.identifier.major == beacon.major.intValue && enumeratedBeacon.tag.identifier.minor == beacon.minor.intValue
				})
				if let beaconToRemove: Beacon = beaconToRemove {
					var currentBeacons: [Beacon] = beacons
					if let idx: Int = currentBeacons.index(of: beaconToRemove) {
						currentBeacons.remove(at: idx)
						self.visibleBeacons[key] = currentBeacons
					}
				}
			}
		}
	}
	
	private func removeObsoleteBeacons(from beacons: inout [UUID: [Beacon]]) {
		let idsToRemove: [String] = self.beaconsToRemove(from: self.beaconsVisibleTimes)
		if idsToRemove.isEmpty { return }
		var removedBeacons: [Beacon] = []
		for beaconId: String in idsToRemove {
			self.beaconsVisibleTimes.removeValue(forKey: beaconId)
			
			let containBlock: ((Beacon) -> Bool) = { (beacon: Beacon) in
				return beacon.tag.identifier.id == beaconId
			}
			
			let foundBeacons: [UUID: [Beacon]] = self.findBeaconsInAllRegions(for: beacons, containingBlock: containBlock)
			
			for (region, beaconsInRegion) in foundBeacons {
				guard let beaconToRemove: Beacon = beaconsInRegion.first(where: containBlock),
					let indexToRemove: Int = beaconsInRegion.index(of: beaconToRemove) else { return }
				removedBeacons.append(beaconToRemove)
				var currentBeacons: [Beacon] = beaconsInRegion
				currentBeacons.remove(at: indexToRemove)
				beacons[region] = currentBeacons
			}
		}
		self.delegate?.rangingManager(self, didReportOutOfRangeBeacons: removedBeacons, with: self.locationManager?.location?.pawscoutLocation)
	}
	
	private func beaconsToRemove(from beacons: [String: TimeInterval]) -> [String] {
		return beacons.compactMap { (arg: (beaconId: String, timestamp: TimeInterval)) in
			let visibleGap: TimeInterval = Date().timeIntervalSince1970 - arg.timestamp
			if visibleGap > TagRangingManager.timeout {
				return arg.beaconId
			} else {
				return nil
			}
		}
	}
	
	private func findBeaconsInAllRegions(for beacons: [UUID: [Beacon]], containingBlock: ((Beacon) -> Bool)) -> [UUID: [Beacon]] {
		return beacons.filter({ (_: UUID, beacons: [Beacon]) in
			let contains: Bool = beacons.contains(where: containingBlock)
			return contains
		})
	}
	
	private func reportLocation(for beacons: [Beacon]) {
		guard let currentLocation: CLLocation = self.locationManager?.location else { return }
		var beaconsToReport: [Beacon] = []
		
		for beacon: Beacon in beacons where self.shouldReportLocation(for: beacon, currentLocation: currentLocation, reportedLocation: self.beaconReportedLocation[beacon.tag.identifier.id]) {
			beaconsToReport.append(beacon)
			print("Current location", currentLocation.timestamp)
			self.beaconReportedLocation[beacon.tag.identifier.id] = currentLocation
		}
		if !beaconsToReport.isEmpty {
			let pawLocation: Location = currentLocation.pawscoutLocation
			self.delegate?.rangingManager(self, didRetrieve: pawLocation, for: beaconsToReport)
		}
	}
	
	func shouldReportLocation(for beacon: Beacon, currentLocation: CLLocation, reportedLocation: CLLocation?) -> Bool {
		guard let reportedLocation: CLLocation = reportedLocation else { return true }
		let delta: TimeInterval = Date().timeIntervalSince(reportedLocation.timestamp)
		if delta > self.sendingRequestInterval {
			return true
		}
		return false
	}
	
	private func updateBeacons(from beacons: [CLBeacon]) {
		for beacon: CLBeacon in beacons {
			var uuiBeacons: [Beacon] = self.visibleBeacons[beacon.proximityUUID] ?? []
			guard let indexOfBeacon: Int = uuiBeacons.firstIndex(where: { (enumeratedBeacon: Beacon) -> Bool in
				return enumeratedBeacon.tag.identifier.major == beacon.major.intValue && enumeratedBeacon.tag.identifier.minor == beacon.minor.intValue
			}) else {
				print("Did not found beacon")
				break
			}
			uuiBeacons[indexOfBeacon].rssi = beacon.rssi
			if let newProximity: Proximity = Proximity(rawValue: beacon.proximity.rawValue) {
				uuiBeacons[indexOfBeacon].proximity = newProximity
			}
			self.visibleBeacons[beacon.proximityUUID] = uuiBeacons
		}
	}
}
