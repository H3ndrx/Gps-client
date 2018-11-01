//
//  Date+Extensions.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 21.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

extension Date {
	var timestamp: Int64 {
		return Int64(self.timeIntervalSince1970 * 1000)
	}
}
