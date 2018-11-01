//
//  BeaconService.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 28.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

protocol BeaconService {
	func didDetectBeacon(with payload: BeaconDetectedPayload, completion: ((_ success: Bool, _ error: Error?) -> Void)?)
}

final class BeaconNetworkService: BeaconService {
	let clientManager: NetworkClientManagerProtocol
	
	init(clientManager: NetworkClientManagerProtocol = Toybox.shared.networkClientManager) {
		self.clientManager = clientManager
	}
	
	func didDetectBeacon(with payload: BeaconDetectedPayload, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		let url: URL = URL.url(forService: .beacon, endpoint: .beacons, path: Path.detected)
		self.clientManager.performRequest(with: url, method: .post, body: payload.json) { (data: Data?, error: Error?) in
			if let data: Data = data, data.isEmpty {
				completion?(true, nil)
			} else {
				completion?(false, error)
			}
		}
	}
}

extension Path {
	static let detected: String = "/detected"
}
