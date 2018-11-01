//
//  PetService.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 13.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

protocol PetService {
	func update(location: Location, for tag: Tag, completion: ((_ success: Bool, _ error: Error?) -> Void)?)
}

final class PetNetworkService: PetService {
	
	let clientManager: NetworkClientManagerProtocol
	let processor: ResponseProcessorProtocol
	
	init(clientManager: NetworkClientManagerProtocol = Toybox.shared.networkClientManager, processor: ResponseProcessorProtocol = ResponseProcessor()) {
		self.clientManager = clientManager
		self.processor = processor
	}
	
	func getLocation(for tag: Tag, completion: ((_ location: Location?, _ error: Error?) -> Void)?) {
		let url: URL = URL.url(forService: .pet, endpoint: .pets, path: Path.coordinates(for: tag))
		self.clientManager.performRequest(with: url, method: .get) { (data: Data?, error: Error?) in
			if let data: Data = data {
				self.processor.process(data: data, completionHandler: completion)
			} else {
				completion?(nil, error)
			}
		}
	}
	
	func update(location: Location, for tag: Tag, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		let url: URL = URL.url(forService: .pet, endpoint: .tags, path: Path.coordinates(for: tag))
		
		self.clientManager.performRequest(with: url, method: .put, body: location.json, priority: .low) { (data: Data?, error: Error?) in
			if let data: Data = data, data.isEmpty {
				completion?(true, nil)
			} else {
				completion?(false, error)
			}
		}
	}
}

extension Path {
	// MARK: Tag
	static func coordinates(for tag: Tag) -> String {
		return "/\(tag.identifier.id)/coordinates"
	}
}
