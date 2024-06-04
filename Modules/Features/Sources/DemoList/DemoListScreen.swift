// Copyright © Fleuronic LLC. All rights reserved.

import enum Demo.Demo

public typealias DemoList = Demo.List

public extension Demo {
	enum List {}
}

// MARK: -
extension DemoList {
	struct Screen {
		let demos: [Demo]
		let selectDemo: (Demo) -> Void
		let canSelectDemo: (Demo) -> Bool
		let isUpdatingDemos: Bool
	}
}
