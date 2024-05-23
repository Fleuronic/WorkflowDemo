// Copyright © Fleuronic LLC. All rights reserved.

import XCTest
import Workflow
import EnumKit

import enum Demo.Demo
import enum Root.Root
import struct DemoAPI.API

@testable import WorkflowUI
@testable import WorkflowContainers
@testable import enum DemoList.DemoList
@testable import enum Counter.Counter

final class AppFlowTests: XCTestCase {
	private let workflowHost = WorkflowHost(
		workflow: Root.Workflow(
			demoService: API()
		)
	)

	func testAppFlow() throws {
		// Start at Demo List
		try verifyShowing(Alert.Screen<DemoList.Screen>.self)
		
		// Show SwiftUI Counter Demo
		try select(.swiftUI)
		try verifyShowing(Counter.SwiftUI.Screen.self)
		try finishDemo()
		
		// Show UIKit Counter Demo
		try select(.uiKit(declarative: false))
		try verifyShowing(Counter.UIKit.Screen.self)
		try finishDemo()
		
		// Show DeclarativeUIKit Counter Demo
		try select(.uiKit(declarative: true))
		try verifyShowing(Counter.DeclarativeUIKit.Screen.self)
		try finishDemo()
		
		// Finish at Demo List
		try verifyShowing(Alert.Screen<DemoList.Screen>.self)
	}
}

// MARK: -
private extension AppFlowTests {
	var screen: BackStack.Screen<AnyScreen> {
		workflowHost.rendering.value
	}

	func select(_ demo: Demo) throws {
		let item = try XCTUnwrap(screen.items.last)
		let alertScreen = try XCTUnwrap(item.screen.wrappedScreen as? Alert.Screen<DemoList.Screen>)
		let screen = alertScreen.baseScreen
		screen.selectDemo(demo)
	}

	func verifyShowing<Screen>(_ screenType: Screen.Type) throws {
		let item = try XCTUnwrap(screen.items.last)
		XCTAssertNotNil(item.screen.wrappedScreen as? Screen)
	}

	func finishDemo() throws {
		let item = try XCTUnwrap(screen.items.last)
		let barContent = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
		let backButton = try XCTUnwrap(barContent.leftItem)
		
		backButton.handler()
	}
}

// MARK: -
extension Bar.Visibility: CaseAccessible {}
