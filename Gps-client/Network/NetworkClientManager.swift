//
//  NetworkClientManager.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 09.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

protocol NetworkClientManagerProtocol {
	var delegate: NetworkClientManagerDelegate? { get set }
	@discardableResult
	func performRequest(with url: URL, method: NetworkMethod, body: JSON?, isSigned: Bool, priority: NetworkRequestPriority, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) -> NetworkTask
}

extension NetworkClientManagerProtocol {
	@discardableResult
	func performRequest(with url: URL, method: NetworkMethod, body: JSON? = nil, isSigned: Bool = true, priority: NetworkRequestPriority = NetworkRequestPriority.normal, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) -> NetworkTask {
		return self.performRequest(with: url, method: method, body: body, isSigned: isSigned, priority: priority, completionHandler: completionHandler)
	}
}

protocol NetworkClientManagerDelegate: class {
	func didRejectToken()
}

final class NetworkClientManager: NetworkClientManagerProtocol {
	let networkClient: NetworkClientProtocol
	
	weak var delegate: NetworkClientManagerDelegate?
	
	init(networkClient: NetworkClientProtocol = NetworkClient()) {
		self.networkClient = networkClient
	}
	
	@discardableResult
	func performRequest(with url: URL, method: NetworkMethod, body: JSON?, isSigned: Bool, priority: NetworkRequestPriority, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) -> NetworkTask {
		let headers: [NetworkRequest.Header] = NetworkRequest.defaultHeaders
		let request: NetworkRequest = NetworkRequest(method: method, url: url, bodyJSON: body, headers: headers, priority: priority)
		
		let handler: ((_ data: Data?, _ error: Error?) -> Void) = { [weak self] (_ data: Data?, _ error: Error?) in
			guard let `self`: NetworkClientManager = self else { return }
			if let data: Data = data {
				completionHandler?(data, nil)
			} else if let error: Error = error {
				self.didReceiveError(error: error, for: request, completionHandler: completionHandler)
			} else {
				completionHandler?(nil, error)
			}
		}
		return self.perform(request: request, completionHandler: handler)
	}
	
	@discardableResult
	private func perform(request: NetworkRequest, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) -> NetworkTask {
		return self.networkClient.perform(request: request, completionHandler: completionHandler)
	}
	
	private func didReceiveError(error: Error, for request: NetworkRequest, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) {
		guard let networkClientError: NetworkClientError = error as? NetworkClientError else {
			completionHandler?(nil, error)
			return
		}
		completionHandler?(nil, networkClientError)
	}
}
