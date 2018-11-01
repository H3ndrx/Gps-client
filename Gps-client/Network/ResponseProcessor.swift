//
//  ResponseProcessor.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 19.10.2017.
//  Copyright © 2017 Pawscout. All rights reserved.
//

import Foundation

enum ResponseProcessorError: Error {
	case unprocessableJson
	case missingData
	case incorrectValue(value: String)
}

extension ResponseProcessorError: LocalizedError {
	var errorDescription: String? {
		return "Internal Server Error."
	}
}

protocol ResponseProcessorProtocol {
	func processError(with data: Data, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?)
	func process<T: Decodable>(data: Data, completionHandler: ((_ decodedObject: T?, _ error: Error?) -> Void)?)
}

final class ResponseProcessor: ResponseProcessorProtocol {
	func processError(with data: Data, completionHandler: ((_ data: Data?, _ error: Error?) -> Void)?) {
		do {
			let decoder: JSONDecoder = JSONDecoder()
			let networkClientError: NetworkClientError = try decoder.decode(NetworkClientError.self, from: data)
			
			completionHandler?(nil, networkClientError)
		} catch {
			completionHandler?(nil, ResponseProcessorError.unprocessableJson)
		}
	}
	
	func process<T: Decodable>(data: Data, completionHandler: ((_ decodedObject: T?, _ error: Error?) -> Void)?) {
		do {
			let values = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
			printd(values)
			let decoder: JSONDecoder = JSONDecoder()
			decoder.dateDecodingStrategy = .millisecondsSince1970
			let decodedObject: T = try decoder.decode(T.self, from: data)
			
			completionHandler?(decodedObject, nil)
		} catch let error {
			completionHandler?(nil, error)
		}
	}
}
