// Copyright © Fleuronic LLC. All rights reserved.

import XCTest
import WorkflowTesting

import enum Demo.Demo
import struct DemoAPI.API

@testable import WorkflowContainers
@testable import enum Root.Root
@testable import enum DemoList.DemoList
@testable import enum Counter.Counter
@testable import struct WorkflowUI.AnyScreen

final class RootWorkflowTests: XCTestCase {
	func testShowCounterDemo() {
		let demo = Demo.swiftUI

		Root.Workflow<API>.Action
			.tester(withState: nil)
			.send(action: .showCounterDemo(demo))
			.assert(state: demo)
			.assertNoOutput()
	}

	func testShowDemoList() {
		Root.Workflow<API>.Action
			.tester(withState: .swiftUI)
			.send(action: .showDemoList)
			.assert(state: nil)
			.assertNoOutput()
	}

	func testDemoListRendering() {
		Root.Workflow(demoService: API()).renderTester().expectWorkflow(
			type: DemoList.Workflow<API>.self,
			producingRendering: .init(
				screen: DemoList.Screen(
					demos: Demo.allCases,
					selectDemo: { _ in },
					canSelectDemo: { _ in false },
					isUpdatingDemos: false
				).asAnyScreen()
			)
		).render { screen in
			XCTAssertEqual(screen.items.count, 1)
		}.assert(state: nil).assertNoAction().assertNoOutput()
	}

	func testDemoListRenderingShowCounterDemo() {
		let demo = Demo.swiftUI

		Root.Workflow(demoService: API()).renderTester().expectWorkflow(
			type: DemoList.Workflow<API>.self,
			producingRendering: .init(
				screen: DemoList.Screen(
					demos: Demo.allCases,
					selectDemo: { _ in },
					canSelectDemo: { _ in false },
					isUpdatingDemos: false
				).asAnyScreen()
			),
			producingOutput: demo
		).render { screen in
			XCTAssertEqual(screen.items.count, 1)
		}.assert(
			state: demo
		).assert(
			action: Root.Workflow.Action.showCounterDemo(demo)
		).assertNoOutput()
	}

	func testSwiftUICounterRendering() throws {
		try Root.Workflow(demoService: API()).renderTester(
			initialState: .swiftUI
		).expectWorkflow(
			type: DemoList.Workflow<API>.self,
			producingRendering: .init(
				screen: DemoList.Screen(
					demos: Demo.allCases,
					selectDemo: { _ in },
					canSelectDemo: { _ in false },
					isUpdatingDemos: false
				).asAnyScreen()
			)
		).expectWorkflow(
			type: Counter.Workflow.self,
			producingRendering: .init(
				screen: Counter.SwiftUI.Screen(
					screen: .init(
						value: 0,
						increment: {},
						decrement: {}
					)
				).asAnyScreen()
			)
		).render { screen in
			let item = try XCTUnwrap(screen.items.last)
			XCTAssertNotNil(item.screen.wrappedScreen as? Counter.SwiftUI.Screen)
		}.assertNoAction().assertNoOutput()
	}

	func testUIKitCounterRendering() throws {
		try Root.Workflow(demoService: API()).renderTester(
			initialState: .uiKit(declarative: false)
		).expectWorkflow(
			type: DemoList.Workflow<API>.self,
			producingRendering: .init(
				screen: DemoList.Screen(
					demos: Demo.allCases,
					selectDemo: { _ in },
					canSelectDemo: { _ in false },
					isUpdatingDemos: false
				).asAnyScreen()
			)
		).expectWorkflow(
			type: Counter.Workflow.self,
			producingRendering: .init(
				screen: Counter.UIKit.Screen(
					screen: .init(
						value: 0,
						increment: {},
						decrement: {}
					)
				).asAnyScreen()
			)
		).render { screen in
			let item = try XCTUnwrap(screen.items.last)
			XCTAssertNotNil(item.screen.wrappedScreen as? Counter.UIKit.Screen)
		}.assertNoAction().assertNoOutput()
	}

	func testDeclarativeUIKitCounterRendering() throws {
		try Root.Workflow(demoService: API()).renderTester(
			initialState: .uiKit(declarative: true)
		).expectWorkflow(
			type: DemoList.Workflow<API>.self,
			producingRendering: .init(
				screen: DemoList.Screen(
					demos: Demo.allCases,
					selectDemo: { _ in },
					canSelectDemo: { _ in false },
					isUpdatingDemos: false
				).asAnyScreen()
			)
		).expectWorkflow(
			type: Counter.Workflow.self,
			producingRendering: .init(
				screen: Counter.DeclarativeUIKit.Screen.wrap(
					screen: .init(
						value: 0,
						increment: {},
						decrement: {}
					)
				)
			)
		).render { screen in
			let item = try XCTUnwrap(screen.items.last)
			XCTAssertNotNil(item.screen.wrappedScreen as? Counter.DeclarativeUIKit.Screen)
		}.assertNoAction().assertNoOutput()
	}

	func testCounterRenderingShowDemoList() throws {
		Root.Workflow(demoService: API()).renderTester(
			initialState: .swiftUI
		).expectWorkflow(
			type: DemoList.Workflow<API>.self,
			producingRendering: .init(
				screen: DemoList.Screen(
					demos: Demo.allCases,
					selectDemo: { _ in },
					canSelectDemo: { _ in false },
					isUpdatingDemos: false
				).asAnyScreen()
			)
		).expectWorkflow(
			type: Counter.Workflow.self,
			producingRendering: .init(
				screen: Counter.SwiftUI.Screen(
					screen: .init(
						value: 0,
						increment: {},
						decrement: {}
					)
				).asAnyScreen()
			),
			producingOutput: ()
		).render { screen in
			XCTAssertEqual(screen.items.count, 2)
		}.assert(
			action: Root.Workflow.Action.showDemoList
		).assert(state: nil).assertNoOutput()
	}
}
