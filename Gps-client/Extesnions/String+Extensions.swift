//
//  String+Extensions.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 12.10.2017.
//  Copyright © 2017 Pawscout. All rights reserved.
//

import UIKit

extension String {
	static let empty: String = ""
	static let comma: String = ","
	static let dash: String = "-"
	static let underScore: String = "_"
	static let space: String = " "
	static let slash: String = "/"
	static let bullet: String = "\u{2022}"
	static let newLine: String = "\n"
	static let dot: String = "."
	static let coreDataSeparator: String = "!@#"
	static let scaleSuffix: String = "@\(Int(UIScreen.main.scale))x.png"
	static let acceptableCharacters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 _+-.,!@#$%^&*();\\/|<>"
	var localized: String {
		return NSLocalizedString(self, comment: String.empty)
	}
	
	func localized(with arguments: CVarArg...) -> String {
		return String(format: self.localized, arguments: arguments)
	}
	
	var trimmed: String {
		return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
	
	var withoutSpaces: String {
		return self.replacingOccurrences(of: String.space, with: String.empty)
	}
	
	func splitByLength(_ length: Int) -> [String] {
		var result: [String] = [String]()
		var collectedCharacters: [Character] = [Character]()
		collectedCharacters.reserveCapacity(length)
		var count: Int = 0
		
		for character: Character in self {
			collectedCharacters.append(character)
			count += 1
			if (count == length) {
				// Reached the desired length
				count = 0
				result.append(String(collectedCharacters))
				collectedCharacters.removeAll(keepingCapacity: true)
			}
		}
		
		// Append the remainder
		if !collectedCharacters.isEmpty {
			result.append(String(collectedCharacters))
		}
		
		return result
	}
	
	func first(numberOfCharacters: Int) -> String {
		return String(self.prefix(numberOfCharacters))
	}
}

extension Optional where Wrapped == String {
	var isNilOrEmpty: Bool {
		return self?.trimmed.isEmpty ?? true
	}
}
