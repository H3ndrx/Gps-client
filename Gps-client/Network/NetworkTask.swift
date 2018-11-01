//
//  NetworkTask.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 19.10.2017.
//  Copyright © 2017 Pawscout. All rights reserved.
//

import Foundation

enum NetworkTaskError: Error {
	case serverResponse(message: String?, status: NetworkResponseStatus)
	case invalidServerResponse(status: NetworkResponseStatus)
	
	var localizedDescription: String {
		switch self {
		case .serverResponse(let message, let status):
			let message: String = message ?? "No error message"
			return "Status: \(status.rawValue)\n Message: \(message)"
		case .invalidServerResponse(let status):
			return "\(self)\nStatus: \(status.rawValue)"
		}
	}
	
	var status: NetworkResponseStatus {
		switch self {
		case .serverResponse(_, let status):
			return status
		case .invalidServerResponse(let status):
			return status
		}
	}
}

extension NetworkTaskError: Equatable {
	static func == (lhs: NetworkTaskError, rhs: NetworkTaskError) -> Bool {
		return lhs.status == rhs.status
	}
}

final class NetworkTask: Operation {
	let completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?
	var request: NetworkRequest
	let session: URLSession
	var dataTask: URLSessionDataTask?
	
	private var _executing: Bool = false
	override var isExecuting: Bool {
		get {
			return self._executing
		}
		set {
			self.willChangeValue(forKey: "isExecuting")
			self._executing = newValue
			self.didChangeValue(forKey: "isExecuting")
		}
	}
	
	private var _finished: Bool = false
	override var isFinished: Bool {
		get {
			return self._finished
		}
		set {
			self.willChangeValue(forKey: "isFinished")
			self._finished = newValue
			self.didChangeValue(forKey: "isFinished")
		}
	}
	
	override var isAsynchronous: Bool {
		return true
	}
	
	init(request: NetworkRequest, session: URLSession, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) {
		self.completionHandler = completionHandler
		self.request = request
		self.session = session
		super.init()
	}
	
	// swiftlint:disable:next cyclomatic_complexity
	override func start() {
		super.start()
		
		if self.isCancelled {
			self.finish(with: nil, error: nil)
			return
		}
		
		let request: URLRequest = self.urlRequest(for: self.request)
	
		let handler: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) = { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
			guard let `self` = self else { return }
			print("Status:", (response as? HTTPURLResponse)?.statusCode, "request:", request.httpMethod!, request.url! )
			guard let status: NetworkResponseStatus = NetworkResponseStatus(statusCode: (response as? HTTPURLResponse)?.statusCode) else {
				self.finish(error: NetworkTaskError.serverResponse(message: error?.localizedDescription, status: .unknown))
				return
			}
			if status == .internalServerError {
				self.finish(error: NetworkTaskError.invalidServerResponse(status: status))
			} else if let data: Data = data, status.isOk {
				self.finish(with: data, error: nil)
			} else if let data: Data = data, !status.isOk {
				self.finish(with: data, error: NetworkTaskError.serverResponse(message: nil, status: status))
			} else if let error: Error = error {
				self.finish(error: error)
			} else {
				self.finish(error: NetworkTaskError.invalidServerResponse(status: status))
			}
		}
	
		self.dataTask = self.session.dataTask(with: request, completionHandler: handler)
		self.dataTask?.resume()
	}
	
	override func cancel() {
		self.dataTask?.cancel()
		super.cancel()
	}
	
	private func finish(with data: Data? = nil, error: Error? = nil) {
		self.completionHandler?(data, error)
		self.isExecuting = false
		self.isFinished = true
	}
	
	private func urlRequest(for request: NetworkRequest) -> URLRequest {
		var urlRequest: URLRequest = URLRequest(url: request.url, timeoutInterval: request.timeoutInterval)
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.httpBody = request.body
		
		for header: (String, String) in request.headers {
			urlRequest.setValue(header.1, forHTTPHeaderField: header.0)
		}
		
		return urlRequest
	}
}
