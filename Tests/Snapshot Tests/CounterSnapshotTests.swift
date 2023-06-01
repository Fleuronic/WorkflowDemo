// Copyright © Fleuronic LLC. All rights reserved.

import XCTest
import ErgoSwiftUITesting
import ErgoUIKitTesting
import ErgoDeclarativeUIKitTesting

@testable import enum Counter.Counter

final class CounterSnapshotTests: XCTestCase {
	func testSwiftUIView() {
		assertView(
			ofType: Counter.SwiftUI.View.self,
			named: "CounterSwiftUIView",
			backedBy: .init(
				screen: .init(
					value: 42,
					increment: {},
					decrement: {}
				)
			),
			matchesSnapshotIn: #filePath
		)
	}

	func testUIKitView() {
		assertView(
			ofType: Counter.UIKit.View.self,
			named: "CounterUIKitView",
			backedBy: .init(
				screen: .init(
					value: 42,
					increment: {},
					decrement: {}
				)
			),
			matchesSnapshotIn: #filePath
		)
	}

	func testDeclarativeUIKitView() {
		assertView(
			ofType: Counter.DeclarativeUIKit.View.self,
			named: "CounterDeclarativeUIKitView",
			backedBy: .init(
				screen: .init(
					value: 42,
					increment: {},
					decrement: {}
				)
			),
			matchesSnapshotIn: #filePath
		)
	}
}
