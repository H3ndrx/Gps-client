//
//  CommonService.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 26.10.2017.
//  Copyright © 2017 Pawscout. All rights reserved.
//

import Foundation

extension URL {
	static let base: URL = URL(string: "http://localhost:8080")!
	
	static func url(forService service: Service, endpoint: Endpoint, path: String = String.empty) -> URL {
		let urlString: String = "\(service.rawValue)\(endpoint.rawValue)\(path)"
		
		guard let url: URL = URL(string: urlString, relativeTo: URL.base) else {
			fatalError("Incorrect string for url")
		}
		return url
	}
}

enum Service: String {
	case user = "/user/api"
	case pet = "/pet/api"
	case mobile = "/mobile/api"
	case beacon = "/beacon/api"
	case resource = "/resource/api"
}

enum Endpoint: String {
	// MARK: User
	case authorization = "/auth"
	case phoneVerification = "/user/phone"
	case password = "/user/password"
	case user = "/user"
	
	// MARK: Pet
	case pets = "/pets"
	case tags = "/tags"
	case devices = "/devices"
	
	// MARK: Beacon
	case beacons = "/beacon"
	
	// MARK: Resource
	case images = "/images"
}

struct Path { }
