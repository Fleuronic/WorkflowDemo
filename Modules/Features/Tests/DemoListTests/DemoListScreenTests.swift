// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

import enum Demo.Demo

@testable import enum DemoList.DemoList

class DemoListScreenTests: XCTestCase {
	func testScreen() {
		let demo = Demo.swiftUI
		var selectedDemo: Demo?

		let screen = DemoList.Screen(
			demos: Demo.allCases,
			selectDemo: { selectedDemo = $0 },
			canSelectDemo: { _ in true },
			isUpdatingDemos: false
		)

		screen.selectDemo(demo)
		XCTAssertEqual(demo, selectedDemo)
	}
}
