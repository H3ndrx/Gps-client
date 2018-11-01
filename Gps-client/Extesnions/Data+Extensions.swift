//
//  Data+Extensions.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 16.04.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

extension Data {
	mutating func append(_ string: String) {
		if let data = string.data(using: .utf8) {
			append(data)
		}
	}
	
	static func data(forJSON json: JSON?) -> Data? {
		guard let json: JSON = json else { return nil }
		do {
			let jsonData: Data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
			return jsonData
		} catch {
			return nil
		}
	}
}
