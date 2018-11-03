//
//  CLLocation+Extensions.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 14.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import CoreLocation

extension CLLocation {
	convenience init(location: Location) {
		self.init(
			coordinate: CLLocationCoordinate2DMake(location.latitude, location.longitude),
			altitude: location.altitude,
			horizontalAccuracy: CLLocationAccuracy(location.accuracy),
			verticalAccuracy: 0,
			timestamp: location.timestamp
		)
	}
	
	var pawscoutLocation: Location {
		return Location(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude, accuracy: self.horizontalAccuracy, altitude: self.altitude, timestamp: self.timestamp)
	}
}
