// Copyright © Fleuronic LLC. All rights reserved.

public enum Counter {}

// MARK: -
public extension Counter {
	struct Screen {
		let value: Int
		let increment: () -> Void
		let decrement: () -> Void
	}
}

// MARK: -
extension Counter.Screen {
	var valueText: String { "The value is \(value)" }
	var incrementTitle: String { "+" }
	var decrementTitle: String { "-" }
}
