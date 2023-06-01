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
		let demo = Demo.swiftUI

		Root.Workflow<API>.Action
			.tester(withState: demo)
			.send(action: .showDemoList)
			.assert(state: nil)
			.assertNoOutput()
	}

	func testDemoListRendering() throws {
		Root.Workflow(
            demoService: API()
        )
		.renderTester()
		.expectWorkflow(
			type: DemoList.Workflow<API>.self,
			producingRendering: .init(
				screen: DemoList.Screen(
					demos: Demo.allCases,
					selectDemo: { _ in },
                    canSelectDemo: { _ in false },
					isUpdatingDemos: false
				).asAnyScreen()
			)
		)
		.render { screen in
			XCTAssertEqual(screen.items.count, 1)
		}
		.assert(state: nil)
		.assertNoAction()
		.assertNoOutput()
	}

	func testDemoListRenderingShowCounterDemo() throws {
		let demo = Demo.swiftUI

        Root.Workflow(demoService: API())
			.renderTester()
			.expectWorkflow(
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
			)
			.render { screen in
				XCTAssertEqual(screen.items.count, 1)
			}
			.assert(state: demo)
			.assert(action: Root.Workflow.Action.showCounterDemo(demo))
			.assertNoOutput()
	}

	func testSwiftUICounterRendering() throws {
		let demo = Demo.swiftUI

        Root.Workflow(demoService: API())
			.renderTester(initialState: demo)
			.expectWorkflow(
				type: DemoList.Workflow<API>.self,
				producingRendering: .init(
					screen: DemoList.Screen(
						demos: Demo.allCases,
						selectDemo: { _ in },
                        canSelectDemo: { _ in false },
						isUpdatingDemos: false
					).asAnyScreen()
				)
			)
			.expectWorkflow(
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
			)
			.render { screen in
				XCTAssertNotNil(screen.items.last?.screen.wrappedScreen as? Counter.SwiftUI.Screen)
			}
			.assertNoAction()
			.assertNoOutput()
	}

	func testUIKitCounterRendering() throws {
		let demo = Demo.uiKit(declarative: false)

        Root.Workflow(demoService: API())
			.renderTester(initialState: demo)
			.expectWorkflow(
				type: DemoList.Workflow<API>.self,
				producingRendering: .init(
					screen: DemoList.Screen(
						demos: Demo.allCases,
						selectDemo: { _ in },
                        canSelectDemo: { _ in false },
						isUpdatingDemos: false
					).asAnyScreen()
				)
			)
			.expectWorkflow(
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
			)
			.render { screen in
				XCTAssertNotNil(screen.items.last?.screen.wrappedScreen as? Counter.UIKit.Screen)
			}
			.assertNoAction()
			.assertNoOutput()
	}

	func testDeclarativeUIKitCounterRendering() throws {
		let demo = Demo.uiKit(declarative: true)

        Root.Workflow(demoService: API())
			.renderTester(initialState: demo)
			.expectWorkflow(
				type: DemoList.Workflow<API>.self,
				producingRendering: .init(
					screen: DemoList.Screen(
						demos: Demo.allCases,
						selectDemo: { _ in },
                        canSelectDemo: { _ in false },
						isUpdatingDemos: false
					).asAnyScreen()
				)
			)
			.expectWorkflow(
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
			)
			.render { screen in
				XCTAssertNotNil(screen.items.last?.screen.wrappedScreen as? Counter.DeclarativeUIKit.Screen)
			}
			.assertNoAction()
			.assertNoOutput()
	}

	func testCounterRenderingShowDemoList() throws {
		let demo = Demo.swiftUI

        Root.Workflow(demoService: API())
			.renderTester(initialState: demo)
			.expectWorkflow(
				type: DemoList.Workflow<API>.self,
				producingRendering: .init(
					screen: DemoList.Screen(
						demos: Demo.allCases,
						selectDemo: { _ in },
                        canSelectDemo: { _ in false },
						isUpdatingDemos: false
					).asAnyScreen()
				)
			)
			.expectWorkflow(
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
			)
			.render { screen in
				XCTAssertEqual(screen.items.count, 2)
			}
			.assert(state: nil)
			.assert(action: Root.Workflow.Action.showDemoList)
			.assertNoOutput()
	}
}
