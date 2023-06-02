// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

@testable import struct DemoAPI.API

final class APITests: XCTestCase {
	func testAPI() {
		let api = API()
		XCTAssertNotNil(api)
	}
}
