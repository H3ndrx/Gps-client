//
//  CommonService.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 26.10.2017.
//  Copyright © 2017 Pawscout. All rights reserved.
//

import Foundation

extension URL {
	static let base: URL = URL(string: "http://192.168.0.73:8080")!
	
	static func url(forEndpoint endpoint: Endpoint, path: String = String.empty) -> URL {
		let urlString: String = "/api/v1\(endpoint.rawValue)\(path)"
		
		guard let url: URL = URL(string: urlString, relativeTo: URL.base) else {
			fatalError("Incorrect string for url")
		}
		return url
	}
}

enum Endpoint: String {
	case tag = "/tag"
}

struct Path { }
