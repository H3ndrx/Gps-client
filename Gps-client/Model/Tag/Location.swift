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
	let accuracy: Double
	let altitude: Double
	let timestamp: Date
	var core: CLLocation {
		return CLLocation(location: self)
	}
	
	enum CodingKeys: String, CodingKey {
		case latitude = "latitude"
		case longitude = "longitude"
		case accuracy = "accuracy"
		case altitude = "altitude"
		case timestamp = "ts"
	}
	
	init(from decoder: Decoder) throws {
		let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
		self.latitude = try container.decode(Double.self, forKey: .latitude)
		self.longitude = try container.decode(Double.self, forKey: .longitude)
		self.accuracy = try container.decode(Double.self, forKey: .accuracy)
		self.altitude = try container.decode(Double.self, forKey: .altitude)
		self.timestamp = try container.decode(Date.self, forKey: .timestamp)
	}
	
	init(latitude: Double, longitude: Double, accuracy: Double, altitude: Double, timestamp: Date = Date()) {
		self.latitude = latitude
		self.longitude = longitude
		self.accuracy = accuracy
		self.timestamp = timestamp
		self.altitude = altitude
	}
}

extension Location: JSONable {
	var json: JSON {
		return ["latitude": self.latitude,
				"longitude": self.longitude,
				"accuracy": self.accuracy,
				"altitude": self.altitude,
				"ts": self.timestamp.timestamp]
	}
}

extension Location: Equatable {
	static func == (lhs: Location, rhs: Location) -> Bool {
		return lhs.latitude == rhs.latitude &&
			lhs.longitude == rhs.longitude &&
			lhs.accuracy == rhs.accuracy &&
			lhs.timestamp == rhs.timestamp
	}
}
