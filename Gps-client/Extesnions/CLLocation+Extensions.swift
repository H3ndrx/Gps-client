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
			altitude: 0.0,
			horizontalAccuracy: CLLocationAccuracy(location.proximity),
			verticalAccuracy: 0,
			timestamp: location.timestamp
		)
	}
	
	var pawscoutLocation: Location {
		return Location(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude, proximity: Int(self.horizontalAccuracy), timestamp: self.timestamp)
	}
}
