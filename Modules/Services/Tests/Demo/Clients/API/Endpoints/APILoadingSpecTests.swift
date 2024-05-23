// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

import enum Demo.Demo

@testable import struct DemoAPI.API

final class APILoadingSpecTests: XCTestCase {
	func testAPILoadDemos() async throws {
		let api = API()
		_ = await api.loadDemos()
		XCTAssert(true)
	}

	func testAPILoadDemosSuccess() async throws {
		let api = API(
			sleep: { _ in },
			randomBool: { true }
		)
		
		let demos = try await api.loadDemos().get()
		XCTAssertEqual(demos, Demo.allCases)
	}

	func testAPILoadDemosFailureLoadError() async throws {
		let api = API(
			sleep: { _ in },
			randomBool: { false }
		)
		
		let result = await api.loadDemos()
		switch result {
		case .failure(.loadError):
			XCTAssert(true)
		default:
			XCTFail()
		}
	}

	func testAPILoadDemosFailureSleepError() async throws {
		let underlyingError = NSError(
			domain: "DemoAPI.API.Error",
			code: 0
		)
		
		let api = API(
			sleep: { _ in throw API.Error.sleepError(underlyingError) },
			randomBool: { true }
		)
		
		switch await api.loadDemos() {
		case let .failure(.sleepError(error as NSError)):
			XCTAssertEqual(error, underlyingError)
		default:
			XCTFail()
		}
	}
}
