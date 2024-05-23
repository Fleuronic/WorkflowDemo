// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

@testable import enum Counter.Counter

class CounterScreenTests: XCTestCase {
	func testScreen() {
		var value = 0
		
		let screen = Counter.Screen(
			value: value,
			increment: { value += 1 },
			decrement: { value -= 1 }
		)
		
		XCTAssertEqual(screen.value, value)
		
		value = 0
		screen.increment()
		XCTAssertEqual(value, 1)
		
		value = 0
		screen.decrement()
		XCTAssertEqual(value, -1)
	}
}
