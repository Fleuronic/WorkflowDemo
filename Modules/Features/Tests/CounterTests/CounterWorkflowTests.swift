// Copyright © Fleuronic LLC. All rights reserved.

import XCTest
import WorkflowTesting
import EnumKit

import enum Demo.Demo

@testable import WorkflowContainers
@testable import enum Counter.Counter
@testable import struct WorkflowUI.AnyScreen

final class CounterWorkflowTests: XCTestCase {
	func testIncrement() {
		Counter.Workflow.Action
			.tester(withState: 0)
			.send(action: .increment)
			.assert(state: 1)
			.assertNoOutput()
	}

	func testDecrement() {
		Counter.Workflow.Action
			.tester(withState: 0)
			.send(action: .decrement)
			.assert(state: -1)
			.assertNoOutput()
	}

	func testReset() {
		Counter.Workflow.Action
			.tester(withState: 5)
			.send(action: .reset)
			.assert(state: 0)
			.assertNoOutput()
	}

	func testFinish() {
		Counter.Workflow.Action.tester(withState: 0).send(
			action: .finish
		).verifyOutput { output in
			XCTAssert(output == ())
		}
	}

	func testRenderingScreen() throws {
		try Counter.Workflow(demo: .swiftUI).renderTester().render { item in
			let screen = try XCTUnwrap(item.screen.wrappedScreen as? Counter.SwiftUI.Screen)
			XCTAssertEqual(screen.valueText, "The value is 0")
			XCTAssertEqual(screen.incrementTitle, "+")
			XCTAssertEqual(screen.decrementTitle, "-")
		}
	}

	func testRenderingBarContent() throws {
		try Counter.Workflow(demo: .swiftUI).renderTester().render { item in
			let barContent = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
			XCTAssertEqual(barContent.title, "SwiftUI Counter Demo")
		}

		try Counter.Workflow(demo: .uiKit(declarative: false)).renderTester().render { item in
			let screen = try XCTUnwrap(item.screen.wrappedScreen as? Counter.UIKit.Screen)
			XCTAssertEqual(screen.value, 0)

			let barContent = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
			XCTAssertEqual(barContent.title, "UIKit Counter Demo")
		}

		try Counter.Workflow(demo: .uiKit(declarative: true)).renderTester().render { item in
			let screen = try XCTUnwrap(item.screen.wrappedScreen as? Counter.DeclarativeUIKit.Screen)
			XCTAssertEqual(screen.value, 0)

			let barContent = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
			XCTAssertEqual(barContent.title, "Declarative UIKit Counter Demo")
		}
	}

	func testRenderingIncrement() throws {
		try Counter.Workflow(demo: .swiftUI).renderTester().render { item in
			let screen = try XCTUnwrap(item.screen.wrappedScreen as? Counter.SwiftUI.Screen)
			screen.increment()
		}.assert(state: 1).assertNoOutput()
	}

	func testRenderingDecrement() throws {
		try Counter.Workflow(demo: .swiftUI).renderTester().render { item in
			let screen = try XCTUnwrap(item.screen.wrappedScreen as? Counter.SwiftUI.Screen)
			screen.decrement()
		}.assert(state: -1).assertNoOutput()
	}

	func testRenderingReset() throws {
		try Counter.Workflow(demo: .swiftUI).renderTester().render { item in
			let content = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
			let rightItem = try XCTUnwrap(content.rightItem)
			rightItem.handler()
		}.assert(state: 0).assertNoOutput()
	}

	func testRenderingFinish() throws {
		try Counter.Workflow(demo: .swiftUI).renderTester().render { item in
			let content = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
			let leftItem = try XCTUnwrap(content.leftItem)
			leftItem.handler()
		}.assert(
			action: Counter.Workflow.Action.finish
		).verifyOutput { output in
			XCTAssert(output == ())
		}
	}
}

// MARK: -
extension Bar.Visibility: CaseAccessible {}
