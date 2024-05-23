// Copyright © Fleuronic LLC. All rights reserved.

public enum Demo: Hashable {
	case swiftUI
	case uiKit(declarative: Bool)
}

// MARK: -
public extension Demo {
	var name: String {
		switch self {
		case .swiftUI:
			"SwiftUI"
		case let .uiKit(declarative):
			declarative ? "Declarative UIKit" : "UIKit"
		}
	}
}

// MARK: -
extension Demo: Identifiable {
	// MARK: Identifiable
	public var id: Self { self }
}

extension Demo: CaseIterable {
	// MARK: CaseIterable
	public static var allCases: [Demo] {
		[
			.swiftUI,
			.uiKit(declarative: false),
			.uiKit(declarative: true)
		]
	}
}
