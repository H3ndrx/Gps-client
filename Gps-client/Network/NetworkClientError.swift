//
//  NetworkClientError.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 26.10.2017.
//  Copyright © 2017 Pawscout. All rights reserved.
//

import Foundation

enum NetworkClientErrorKind: Int, Decodable {
	case shouldNotHappen = 0
	case userNotFound = 1
	case userAlreadyExist = 2
	case authorizationException = 4
	case unauthorizedChange = 5
	case resetCodeExpired = 6
	case insufficientLoginData = 10
	case refreshTokenInvalid = 12
}

struct NetworkClientError: Error, Decodable {
	let kind: NetworkClientErrorKind
	let message: String
	
	enum CodingKeys: String, CodingKey {
		case kind = "errorCode"
		case message
	}
	
	var localizedDescription: String {
		return "\(type(of: self)).\(self.kind) - \(self.message)"
	}
	
	init(kind: NetworkClientErrorKind, message: String = String.empty) {
		self.kind = kind
		self.message = message
	}
}

extension NetworkClientError: Equatable {
	static func == (lhs: NetworkClientError, rhs: NetworkClientError) -> Bool {
		return lhs.kind == rhs.kind
	}
}
