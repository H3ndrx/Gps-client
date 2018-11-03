//
//  BeaconService.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 28.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import UIKit

protocol BeaconService {
	func didDetectBeacon(with payload: BeaconDetectedPayload, completion: ((_ success: Bool, _ error: Error?) -> Void)?)
	func update(location: Location, for tag: Tag, completion: ((_ success: Bool, _ error: Error?) -> Void)?)
	func getLocation(for tag: Tag, completion: ((_ location: Location?, _ error: Error?) -> Void)?)
}

final class BeaconNetworkService: BeaconService {
	let clientManager: NetworkClientManagerProtocol
	let processor: ResponseProcessorProtocol
	
	init(clientManager: NetworkClientManagerProtocol = Toybox.shared.networkClientManager, processor: ResponseProcessorProtocol = ResponseProcessor()) {
		self.clientManager = clientManager
		self.processor = processor
	}
	
	func didDetectBeacon(with payload: BeaconDetectedPayload, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		let url: URL = URL.url(forEndpoint: .tag, path: Path.detected)
		self.clientManager.performRequest(with: url, method: .post, body: payload.json) { (data: Data?, error: Error?) in
			if let data: Data = data, data.isEmpty {
				completion?(true, nil)
			} else {
				completion?(false, error)
			}
		}
	}
	
	func getLocation(for tag: Tag, completion: ((_ location: Location?, _ error: Error?) -> Void)?) {
		let url: URL = URL.url(forEndpoint: .tag, path: Path.coordinates(for: tag))
		self.clientManager.performRequest(with: url, method: .get) { (data: Data?, error: Error?) in
			if let data: Data = data {
				self.processor.process(data: data, completionHandler: completion)
			} else {
				completion?(nil, error)
			}
		}
	}
	
	func update(location: Location, for tag: Tag, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		guard let deviceId: String = UIDevice.current.identifierForVendor?.uuidString else { fatalError("NO ID FOR VENDOR") }
		let url: URL = URL.url(forEndpoint: .tag, path: Path.coordinates(for: tag))
		
		self.clientManager.performRequest(with: url, method: .post, body: location.json, priority: .low) { (data: Data?, error: Error?) in
			if let data: Data = data, data.isEmpty {
				completion?(true, nil)
			} else {
				completion?(false, error)
			}
		}
	}
}

extension Path {
	static let detected: String = "/beaconDetected"
	
	static func coordinates(for tag: Tag) -> String {
		return "/\(tag.identifier.id)/updateLocation"
	}
}
