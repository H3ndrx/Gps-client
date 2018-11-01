//
//  CLLocationManager+Extensions.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 31.01.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation
import CoreLocation

protocol CLLocationManagerWrapper {
	var isUpdatingLocation: Bool { get }
	var isMonitoringVisits: Bool { get }
	var location: CLLocation? { get }
	var canRetrieveLocation: Bool { get }
	var authorizationStatus: CLAuthorizationStatus { get }
	var monitoredRegions: Set<CLRegion> { get }
	var distanceFilter: CLLocationDistance { get set }
	var delegate: CLLocationManagerDelegate? { get set }
	var desiredAccuracy: CLLocationAccuracy { get set }
	var allowsBackgroundLocationUpdates: Bool { get set }
	var pausesLocationUpdatesAutomatically: Bool { get set }
	var rangedRegions: Set<CLRegion> { get }
	var activityType: CLActivityType { get set }
	
	@available(iOS 11.0, *)
	var showsBackgroundLocationIndicator: Bool { get set }
	
	func startMonitoring(for region: CLRegion)
	func stopMonitoring(for region: CLRegion)
	func isMonitoringAvailable(for regionClass: AnyClass) -> Bool
	func requestAlwaysAuthorization()
	func startMonitoringSignificantLocationChanges()
	
	func startRangingBeacons(in region: CLBeaconRegion)
	func stopRangingBeacons(in region: CLBeaconRegion)
	
	func startUpdatingLocation()
	func stopUpdatingLocation()
	func requestLocation()
	
	func startMonitoringVisits()
}

@available(iOS 10.3, *)
extension CLLocationManager: CLLocationManagerWrapper {
	var isUpdatingLocation: Bool {
		return false
	}
	
	var isMonitoringVisits: Bool {
		return false
	}
	
	var canRetrieveLocation: Bool {
		switch CLLocationManager.authorizationStatus() {
		case .denied, .restricted, .notDetermined, .authorizedWhenInUse:
			return false
		case .authorizedAlways:
			return true
		}
	}
	
	var authorizationStatus: CLAuthorizationStatus {
		return CLLocationManager.authorizationStatus()
	}
	
	func isMonitoringAvailable(for regionClass: AnyClass) -> Bool {
		return CLLocationManager.isMonitoringAvailable(for: regionClass)
	}
}
