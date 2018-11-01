//
//  NetworkClient.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 18.10.2017.
//  Copyright © 2017 Pawscout. All rights reserved.
//

import Foundation

enum NetworkMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
}

enum NetworkResponseStatus: Int {
	case unknown = 0
	case ok = 200
	case created = 201
	case deleted = 204
	case badRequest = 400
	case unauthorized = 401
	case forbidden = 403
	case notFound = 404
	case conflict = 409
	case unprocessableEntity = 422
	case internalServerError = 500
	
	var isOk: Bool {
		return self == .ok || self == .created || self == .deleted
	}
	
	init?(statusCode: Int?) {
		guard let statusCode: Int = statusCode else { return nil }
		self.init(rawValue: statusCode)
	}
}

protocol NetworkClientProtocol {
	var tasks: [NetworkTask] { get }
	@discardableResult
	func perform(request: NetworkRequest, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) -> NetworkTask
	func suspendAllTasks()
	func resumeAllTasks()
}

final class NetworkClient: NetworkClientProtocol {
	static let defaultTimeoutInterval: TimeInterval = 10.0
	
	let session: URLSession
	let queue: OperationQueue
	let responseProcessor: ResponseProcessorProtocol
	var tasks: [NetworkTask] {
		return self.queue.operations.compactMap({ (operation: Operation) -> NetworkTask? in
			return operation as? NetworkTask
		})
	}
	
	init(session: URLSession, queue: OperationQueue, responseProcessor: ResponseProcessorProtocol) {
		self.session = session
		self.queue = queue
		self.responseProcessor = responseProcessor
	}
	
	convenience init() {
		let queue: OperationQueue = OperationQueue()
		queue.maxConcurrentOperationCount = 10
		
		let configuration: URLSessionConfiguration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = NetworkClient.defaultTimeoutInterval
		
		let session: URLSession = URLSession(configuration: configuration)
		
		let processor: ResponseProcessor = ResponseProcessor()
		
		self.init(session: session, queue: queue, responseProcessor: processor)
	}
	
	@discardableResult
	func perform(request: NetworkRequest, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) -> NetworkTask {
		let handler: ((_ data: Data?, _ error: Error?) -> Void) = { [weak self] (_ data: Data?, _ error: Error?) in
			self?.updateNetworkActivityIndicator()
			guard let `self`: NetworkClient = self else { return }
			if let data: Data = data, let _: Error = error {
				self.responseProcessor.processError(with: data, completionHandler: completionHandler)
			} else if let data: Data = data {
				completionHandler?(data, nil)
			} else {
				completionHandler?(nil, error)
			}
		}
		
		let task: NetworkTask = NetworkTask(request: request, session: self.session, completionHandler: handler)
		switch request.priority {
		case .low:
			task.queuePriority = .veryLow
			task.qualityOfService = .background
		case .normal:
			task.queuePriority = .normal
			task.qualityOfService = .userInitiated
		case .high:
			task.queuePriority = .veryHigh
			task.qualityOfService = .userInteractive
		}
		
		self.queue.addOperation(task)
		
		return task
	}
	
	func suspendAllTasks() {
		self.queue.isSuspended = true
	}
	
	func resumeAllTasks() {
		self.queue.isSuspended = false
	}
	
	var hasOperationsRunning: Bool {
		return self.queue.operations.contains { $0.isExecuting }
	}
	
	private func updateNetworkActivityIndicator() {
//		DispatchQueue.main.async {
//			UIApplication.shared.isNetworkActivityIndicatorVisible = self.hasOperationsRunning
//		}
	}
}
