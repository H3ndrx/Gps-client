//
//  Toybox.swift
//  Pawscout
//
//  Created by Kuba Reinhard on 09.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

final class Toybox {
	static let shared: Toybox = Toybox()
	
	private init() {}
	
	lazy var tagManager: TagManager = {
		return TagManager()
	}()
	
	lazy var networkClientManager: NetworkClientManagerProtocol = {
		return NetworkClientManager()
	}()
}
