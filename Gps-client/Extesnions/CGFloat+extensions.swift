//
//  CGFloat+extensions.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 02.01.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import UIKit

extension CGFloat {
	typealias Degrees = CGFloat
	
	static func radians(from degrees: Degrees) -> CGFloat {
		return (CGFloat.pi * degrees) / 180.0
	}
}
