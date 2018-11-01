//
//  Beacon.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 07.03.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

struct Beacon {
	let tag: Tag
	let proximityUUID: UUID
	var rssi: Int
	var proximity: Proximity
	
	init(tag: Tag, proximityUUID: UUID, rssi: Int, proximity: Proximity) {
		self.tag = tag
		self.proximityUUID = proximityUUID
		self.rssi = rssi
		self.proximity = proximity
	}
}

extension Beacon: Equatable {
	static func == (lhs: Beacon, rhs: Beacon) -> Bool {
		return lhs.tag == rhs.tag
	}
}

enum Proximity: Int {
	case unknown
	case immediate
	case near
	case far
}
