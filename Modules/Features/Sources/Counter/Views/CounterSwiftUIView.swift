// Copyright © Fleuronic LLC. All rights reserved.

import SwiftUI
import ErgoSwiftUI

extension Counter.SwiftUI {
	struct View {}
}

// MARK: -
extension Counter.SwiftUI.View: BodyProvider {
	// MARK: ScreenBacked
	typealias Screen = Counter.SwiftUI.Screen

	// MARK: BodyProvider
	static func body(with screen: Screen) -> some View {
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
	typealias View = Counter.SwiftUI.View
}
