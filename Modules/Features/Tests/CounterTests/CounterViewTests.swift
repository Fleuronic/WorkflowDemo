// Copyright © Fleuronic LLC. All rights reserved.

import XCTest
import ErgoUIKitTesting
import ErgoDeclarativeUIKitTesting
import ViewInspector
import ErrorAssertionExpectations

@testable import ErgoUIKit
@testable import ErgoDeclarativeUIKit
@testable import enum Counter.Counter

final class CounterViewTests: XCTestCase {
	func testSwiftUIView() throws {
		let incrementExpectation = expectation(description: "increment")
		let decrementExpectation = expectation(description: "decrement")
		let screen = Counter.SwiftUI.Screen(
			screen: .init(
				value: 42,
				increment: incrementExpectation.fulfill,
				decrement: decrementExpectation.fulfill
			)
		)
		
		let body = Counter.SwiftUI.View.body(with: screen)
		let stack = try body.inspect().vStack()
		let valueText = try stack.text(0)
		let incrementButton = try stack.button(1)
		let decrementButton = try stack.button(2)
		
		try XCTAssertEqual(valueText.string(), screen.valueText)
		try XCTAssertEqual(incrementButton.labelView().text().string(), screen.incrementTitle)
		try XCTAssertEqual(decrementButton.labelView().text().string(), screen.decrementTitle)
		
		try incrementButton.tap()
		try decrementButton.tap()
		wait(for: [incrementExpectation, decrementExpectation], enforceOrder: true)
	}

	func testUIKitView() throws {
		let incrementExpectation = expectation(description: "increment")
		let decrementExpectation = expectation(description: "decrement")
		let screen = Counter.UIKit.Screen(
			screen: .init(
				value: 42,
				increment: incrementExpectation.fulfill,
				decrement: decrementExpectation.fulfill
			)
		)
		
		let view = Counter.UIKit.View(screen: screen)
		view.update(with: screen)
		
		let stackView = try view.stackView()
		let valueLabel = try stackView.label(0)
		let incrementButton = try stackView.button(1)
		let decrementButton = try stackView.button(2)
		
		XCTAssertEqual(valueLabel.text, screen.valueText)
		XCTAssertEqual(incrementButton.title(for: .normal), screen.incrementTitle)
		XCTAssertEqual(decrementButton.title(for: .normal), screen.decrementTitle)
		
		incrementButton.tap()
		decrementButton.tap()
		wait(for: [incrementExpectation, decrementExpectation], enforceOrder: true)
		
		expectFatalError { _ = Counter.UIKit.View(coder: .init()) }
	}

	func testDeclarativeUIKitView() throws {
		let incrementExpectation = expectation(description: "increment")
		let decrementExpectation = expectation(description: "decrement")
		let screen = Counter.DeclarativeUIKit.Screen(
			screen: .init(
				value: 42,
				increment: incrementExpectation.fulfill,
				decrement: decrementExpectation.fulfill
			)
		)
		let viewController = LayoutViewController<Counter.DeclarativeUIKit.View>(
			screen: screen,
			environment: .empty
		)
		
		let view = Counter.DeclarativeUIKit.View()
		view.layout(with: viewController).layout(in: view)
		
		let stackView = try view.stackView()
		let valueLabel = try stackView.label(0)
		let incrementButton = try stackView.button(1)
		let decrementButton = try stackView.button(2)
		
		XCTAssertEqual(valueLabel.text, screen.valueText)
		XCTAssertEqual(incrementButton.title(for: .normal), screen.incrementTitle)
		XCTAssertEqual(decrementButton.title(for: .normal), screen.decrementTitle)
		
		incrementButton.invokeAction()
		decrementButton.invokeAction()
		wait(for: [incrementExpectation, decrementExpectation], enforceOrder: true)
	}
}
