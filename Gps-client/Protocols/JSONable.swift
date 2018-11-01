//
//  JSONable.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 16.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

protocol JSONable {
	var json: JSON { get }
}
