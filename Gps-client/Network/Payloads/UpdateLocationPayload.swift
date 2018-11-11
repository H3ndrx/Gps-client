//
//  UpdateLocationPayload.swift
//  Gps-client
//
//  Created by Gabriel Zolnierczuk on 11/11/2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

struct UpdateLocationPayload {
	let location: Location
	let deviceId: String
}

extension UpdateLocationPayload: JSONable {
	var json: JSON {
		return ["deviceId": self.deviceId,
				"location": self.location.json]
	}
}
