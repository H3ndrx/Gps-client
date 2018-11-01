//
//  Tag.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 16.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation
import CoreLocation

struct Tag: Decodable {
	let identifier: TagIdentifier
	let location: Location?
	let firmwareVersion: String
	let hardwareVersion: String
	
	let inRange: Bool?
	let hasUpdate: Bool?
	let hasLowBattery: Bool?
	
	enum CodingKeys: String, CodingKey {
		case tagId
		case locationDetails
		case firmwareVersion
		case hardwareVersion
	}
	
	init(from decoder: Decoder) throws {
		let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
		self.identifier = try container.decode(TagIdentifier.self, forKey: .tagId)
		self.location = try? container.decode(Location.self, forKey: .locationDetails)
		self.firmwareVersion = try container.decode(String.self, forKey: .firmwareVersion)
		self.hardwareVersion = try container.decode(String.self, forKey: .hardwareVersion)
		self.inRange = nil
		self.hasUpdate = nil
		self.hasLowBattery = nil
	}
	
	init(major: Int, minor: Int, location: Location? = nil, firmwareVersion: String = String.empty, hardwareVersion: String = String.empty, inRange: Bool? = nil, hasUpdate: Bool? = nil, hasLowBattery: Bool? = nil) {
		self.identifier = TagIdentifier(major: major, minor: minor)
		self.location = location
		self.firmwareVersion = firmwareVersion
		self.hardwareVersion = hardwareVersion
		self.inRange = inRange
		self.hasUpdate = hasUpdate
		self.hasLowBattery = hasLowBattery
	}
}

extension Tag: JSONable {
	var json: JSON {
		return ["tagId": self.identifier.json,
				"firmwareVersion": self.firmwareVersion,
				"hardwareVersion": self.hardwareVersion]
	}
}

extension Tag: Equatable {
	static func == (lhs: Tag, rhs: Tag) -> Bool {
		return lhs.identifier == rhs.identifier
	}
}
