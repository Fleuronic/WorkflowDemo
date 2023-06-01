// Copyright © Fleuronic LLC. All rights reserved.

import UIKit
import Geometric
import Telemetric
import Layoutless
import ErgoDeclarativeUIKit

import enum Demo.Demo

public extension DemoList {
	class View: UIView {}
}

// MARK: -
extension DemoList.View: LayoutProvider {
	// MARK: ScreenBacked
	public typealias Screen = DemoList.Screen

	// MARK: LayoutProvider
	public func layout(with screen: some ScreenProxy<Screen>) -> AnyLayout {
		UITableView.style(.insetGrouped)
            .items(
                screen.demos,
                text: \.name,
                loading: screen.isUpdatingDemos,
                canSelectItem: screen.canSelectDemo.value
            )
			.itemSelected(screen.selectDemo)
			.fillingParent()
	}
}

// MARK: -
extension DemoList.Screen: LayoutBackingScreen {
	// MARK: LayoutBackingScreen
	public typealias View = DemoList.View
}
