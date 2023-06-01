// Copyright © Fleuronic LLC. All rights reserved.

import protocol Ergo.WrappedScreen

public extension Counter {
	enum SwiftUI {}
	enum UIKit {}
	enum DeclarativeUIKit {}
}

// MARK: -
public extension Counter.SwiftUI {
	@dynamicMemberLookup
	struct Screen: WrappedScreen {
		private let screen: Counter.Screen

		public init(screen: Counter.Screen) {
			self.screen = screen
		}

		subscript<Value>(dynamicMember keyPath: KeyPath<Counter.Screen, Value>) -> Value {
			screen[keyPath: keyPath]
		}
	}
}

// MARK: -
public extension Counter.UIKit {
	@dynamicMemberLookup
	struct Screen: WrappedScreen {
		private let screen: Counter.Screen

		public init(screen: Counter.Screen) {
			self.screen = screen
		}

		subscript<Value>(dynamicMember keyPath: KeyPath<Counter.Screen, Value>) -> Value {
			screen[keyPath: keyPath]
		}
	}
}

// MARK: -
public extension Counter.DeclarativeUIKit {
	@dynamicMemberLookup
	struct Screen: WrappedScreen {
		private let screen: Counter.Screen

		public init(screen: Counter.Screen) {
			self.screen = screen
		}

		subscript<Value>(dynamicMember keyPath: KeyPath<Counter.Screen, Value>) -> Value {
			screen[keyPath: keyPath]
		}
	}
}
