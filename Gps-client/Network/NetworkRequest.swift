//
//  NetworkRequest.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 26.10.2017.
//  Copyright © 2017 Pawscout. All rights reserved.
//

import Foundation

enum NetworkRequestPriority {
	case low
	case normal
	case high
}

struct NetworkRequest {
	typealias Header = (field: String, value: String)
	let method: NetworkMethod
	let url: URL
	let timeoutInterval: TimeInterval
	let body: Data?
	let headers: [Header]
	let priority: NetworkRequestPriority
	var isSigned: Bool {
		return self.headers.contains(where: { (field: String, _: String) -> Bool in
			field == "Authorization"
		})
	}
	
	static let defaultHeaders: [Header] = [("Accept", "application/json"), ("Content-Type", "application/json")]
	
	init(method: NetworkMethod, url: URL, bodyJSON: JSON?, timeoutInterval: TimeInterval = NetworkClient.defaultTimeoutInterval, headers: [Header]? = NetworkRequest.defaultHeaders, priority: NetworkRequestPriority = NetworkRequestPriority.normal) {
		self.method = method
		self.url = url
		self.timeoutInterval = timeoutInterval
		self.body = Data.data(forJSON: bodyJSON)
		self.headers = headers ?? []
		self.priority = priority
	}
}
