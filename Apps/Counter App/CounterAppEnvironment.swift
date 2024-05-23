// Copyright © Fleuronic LLC. All rights reserved.

import Foundation

import enum Demo.Demo
import enum Counter.Counter

extension Counter.App {
	@propertyWrapper struct Environment {
		private let key: Key
		
		init(_ key: Key) {
			self.key = key
		}
		
		var wrappedValue: Demo {
			ProcessInfo.processInfo
				.environment[key.rawValue]
				.flatMap(Value.init(rawValue:))
				.map(Demo.init)!
		}
	}
}

// MARK: -
extension Counter.App.Environment {
	enum Key: String {
		case demo
	}

	enum Value: String {
		case swiftUI
		case uiKit
		case declarativeUIKit
	}
}

// MARK: -
extension Demo {
	init(_ value: Counter.App.Environment.Value) {
		switch value {
		case .swiftUI:
			self = .swiftUI
		case .uiKit:
			self = .uiKit(declarative: false)
		case .declarativeUIKit:
			self = .uiKit(declarative: true)
		}
	}
}
