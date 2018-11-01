//
//  TagIdentifier.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 27.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

struct TagIdentifier: Decodable {
	let major: Int
	let minor: Int
	var id: String {
		return "\(self.major).\(self.minor)"
	}
	
	init(major: Int, minor: Int) {
		self.major = major
		self.minor = minor
	}
}

extension TagIdentifier: JSONable {
	var json: JSON {
		return ["major": self.major,
				"minor": self.minor]
	}
}

extension TagIdentifier: Equatable {
	static func == (lhs: TagIdentifier, rhs: TagIdentifier) -> Bool {
		return lhs.major == rhs.major && lhs.minor == rhs.minor
	}
}
