// Copyright © Fleuronic LLC. All rights reserved.

import SwiftUI
import ErgoSwiftUI

public extension Counter.SwiftUI {
	struct View {
		public init() {}
	}
}

// MARK: -
extension Counter.SwiftUI.View: BodyProvider {
	// MARK: ScreenBacked
	public typealias Screen = Counter.SwiftUI.Screen

	// MARK: BodyProvider
	public static func body(with screen: Screen) -> some View {
		VStack {
			Text(screen.valueText)
			Button(action: screen.increment) {
				Text(screen.incrementTitle)
			}
			Button(action: screen.decrement) {
				Text(screen.decrementTitle)
			}
		}
	}
}

// MARK: -
extension Counter.SwiftUI.Screen: BodyBackingScreen {
	// MARK: BodyBackingScreen
	public typealias View = Counter.SwiftUI.View
}
