// Copyright © Fleuronic LLC. All rights reserved.

import UIKit
import Telemetric
import Layoutless
import ErgoDeclarativeUIKit

public extension Counter.DeclarativeUIKit {
	final class View: UIView {}
}

// MARK: -
extension Counter.DeclarativeUIKit.View: LayoutProvider {
	// MARK: ScreenBacked
	public typealias Screen = Counter.DeclarativeUIKit.Screen

	// MARK: LayoutProvider
	public func layout(with screen: some ScreenProxy<Screen>) -> AnyLayout {
		UIStackView.vertical.layout {
			UILabel.default
				.text(screen.valueText)
			UIButton.default
				.title(screen.incrementTitle)
				.tapped(screen.increment)
			UIButton.default
				.title(screen.decrementTitle)
				.tapped(screen.decrement)
		}.centeringInParent()
	}
}

// MARK: -
extension Counter.DeclarativeUIKit.Screen: LayoutBackingScreen {
	// MARK: LayoutBackingScreen
	public typealias View = Counter.DeclarativeUIKit.View
}
