//
//  URL+Extensions.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 14.03.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

extension URL {
	static let empty: URL = URL(string: "http://google.com")!
	
	init?(string: String?) {
		guard let string: String = string else { return nil }
		self.init(string: string)
	}
}
