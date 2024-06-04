// Copyright © Fleuronic LLC. All rights reserved.

import UIKit
import Geometric
import Telemetric
import Layoutless
import ErgoDeclarativeUIKit

import enum Demo.Demo

extension DemoList {
	final class View: UIView {}
}

// MARK: -
extension DemoList.View: LayoutProvider {
	// MARK: ScreenBacked
	typealias Screen = DemoList.Screen

	// MARK: LayoutProvider
	func layout(with screen: some ScreenProxy<Screen>) -> AnyLayout {
		UITableView.style(.insetGrouped).content(
			items: screen.demos,
			text: \.name,
			loading: screen.isUpdatingDemos,
			canSelectItem: screen.canSelectDemo.value
		).itemSelected(screen.selectDemo).fillingParent()
	}
}

// MARK: -
extension DemoList.Screen: LayoutBackingScreen {
	// MARK: LayoutBackingScreen
	typealias View = DemoList.View
}
