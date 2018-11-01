//
//  BeaconDetectedPayload.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 28.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

struct BeaconDetectedPayload {
	let tagIdentifier: TagIdentifier
	let deviceId: String
	let location: Location
	let signal: Int
}

extension BeaconDetectedPayload: JSONable {
	var json: JSON {
		return ["beaconId": self.tagIdentifier.id,
				"deviceId": self.deviceId,
				"location": self.location.json,
				"signal": self.signal]
	}
}
