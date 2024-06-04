// Copyright © Fleuronic LLC. All rights reserved.

import WorkflowUI

extension Counter {
	enum SwiftUI {}
	enum UIKit {}
	enum DeclarativeUIKit {}
}

// MARK: -
extension Counter.SwiftUI {
	@dynamicMemberLookup
	struct Screen: WrappedScreen {
		private let screen: Counter.Screen
		
		init(screen: Counter.Screen) {
			self.screen = screen
		}
		
		subscript<Value>(dynamicMember keyPath: KeyPath<Counter.Screen, Value>) -> Value {
			screen[keyPath: keyPath]
		}
	}
}

// MARK: -
extension Counter.UIKit {
	@dynamicMemberLookup
	struct Screen: WrappedScreen {
		private let screen: Counter.Screen
		
		init(screen: Counter.Screen) {
			self.screen = screen
		}
		
		subscript<Value>(dynamicMember keyPath: KeyPath<Counter.Screen, Value>) -> Value {
			screen[keyPath: keyPath]
		}
	}
}

// MARK: -
extension Counter.DeclarativeUIKit {
	@dynamicMemberLookup
	struct Screen: WrappedScreen {
		private let screen: Counter.Screen
		
		init(screen: Counter.Screen) {
			self.screen = screen
		}
		
		subscript<Value>(dynamicMember keyPath: KeyPath<Counter.Screen, Value>) -> Value {
			screen[keyPath: keyPath]
		}
	}
}

// MARK: -
protocol WrappedScreen: Screen {
	associatedtype Screen

	init(screen: Screen)
}

// MARK: -
extension WrappedScreen {
	static func wrap(screen: Screen) -> AnyScreen {
		self.init(screen: screen).asAnyScreen()
	}
}
