//
//  Location.swift
//  
//
//  Created by Gabriel Zolnierczuk on 22/02/2018.
//

import CoreLocation

struct Location: Decodable {
	let latitude: Double
	let longitude: Double
	let proximity: Int
	let timestamp: Date
	var core: CLLocation {
		return CLLocation(location: self)
	}
	
	enum CodingKeys: String, CodingKey {
		case latitude = "lat"
		case longitude = "lng"
		case proximity = "prox"
		case timestamp = "ts"
	}
	
	init(from decoder: Decoder) throws {
		let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
		self.latitude = try container.decode(Double.self, forKey: .latitude)
		self.longitude = try container.decode(Double.self, forKey: .longitude)
		self.proximity = try container.decode(Int.self, forKey: .proximity)
		self.timestamp = try container.decode(Date.self, forKey: .timestamp)
	}
	
	init(latitude: Double, longitude: Double, proximity: Int, timestamp: Date = Date()) {
		self.latitude = latitude
		self.longitude = longitude
		self.proximity = proximity
		self.timestamp = timestamp
	}
}

extension Location: Equatable {
	static func == (lhs: Location, rhs: Location) -> Bool {
		return lhs.latitude == rhs.latitude &&
			lhs.longitude == rhs.longitude &&
			lhs.proximity == rhs.proximity &&
			lhs.timestamp == rhs.timestamp
	}
}

extension Location: JSONable {
	var json: JSON {
		return ["lat": self.latitude,
				"lng": self.longitude,
				"prox": self.proximity,
				"ts": self.timestamp.timestamp]
	}
}
