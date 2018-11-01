//
//  Extensions.swift
//  Gps-client
//
//  Created by Gabriel Zolnierczuk on 13.05.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

func printd(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	let output: String = items.map { "\($0)" }.joined(separator: separator)
	Swift.print("🧙🏼‍♂️", output, terminator: terminator)
}

extension TimeInterval {
	static let time5min: TimeInterval = 5 * 60
	static let time15min: TimeInterval = 15 * 60
}
