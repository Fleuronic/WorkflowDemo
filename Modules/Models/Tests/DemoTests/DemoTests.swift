// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

import enum Demo.Demo

final class DemoTests: XCTestCase {
	func testName() {
		XCTAssertEqual(Demo.swiftUI.name, "SwiftUI")
		XCTAssertEqual(Demo.uiKit(declarative: false).name, "UIKit")
		XCTAssertEqual(Demo.uiKit(declarative: true).name, "Declarative UIKit")
	}

	func testAllCases() {
		let demos: [Demo] = [
			.swiftUI,
			.uiKit(declarative: false),
			.uiKit(declarative: true)
		]

		XCTAssertEqual(Demo.allCases, demos)
	}

	func testID() {
		let demo = Demo.swiftUI
		XCTAssertEqual(demo.id, demo)
	}
}
