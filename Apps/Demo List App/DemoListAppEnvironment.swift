// Copyright © Fleuronic LLC. All rights reserved.

import Foundation

import enum DemoList.DemoList

extension DemoList.App {
	@propertyWrapper struct Environment {
		private let key: Key
		
		init(_ key: Key) {
			self.key = key
		}
		
		var wrappedValue: String? {
			ProcessInfo.processInfo.environment[key.rawValue]
		}
	}
}

// MARK: -
extension DemoList.App.Environment {
	enum Key: String {
		case canUpdateDemos
		case updateDuration
	}
}
