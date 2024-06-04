// Copyright © Fleuronic LLC. All rights reserved.

import UIKit
import ErgoUIKit
import ErrorAssertions

extension Counter.UIKit {
	final class View: UIView {
		private let stackView: UIStackView
		private let valueLabel: UILabel
		private let incrementButton: UIButton
		private let decrementButton: UIButton
		private let increment: () -> Void
		private let decrement: () -> Void
		
		// MARK: NSCoding
		required init(coder: NSCoder) { fatalError() }
		
		// MARK: Updating
		init(screen: Screen) {
			valueLabel = .init()
			incrementButton = .init(type: .system)
			decrementButton = .init(type: .system)
			stackView = .init(arrangedSubviews: [valueLabel, incrementButton, decrementButton])
			increment = screen.increment
			decrement = screen.decrement
			
			super.init(frame: .zero)
			
			incrementButton.addTarget(self, action: #selector(incrementButtonTapped), for: .touchUpInside)
			decrementButton.addTarget(self, action: #selector(decrementButtonTapped), for: .touchUpInside)
			
			addSubview(stackView)
			stackView.axis = .vertical
			stackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		}
	}
}

// MARK: -
extension Counter.UIKit.View: Updating {
	// MARK: ScreenBacked
	typealias Screen = Counter.UIKit.Screen

	// MARK: Updating
	func update(with screen: Screen) {
		valueLabel.text = screen.valueText
		incrementButton.setTitle(screen.incrementTitle, for: .normal)
		decrementButton.setTitle(screen.decrementTitle, for: .normal)
	}
}

// MARK: -
private extension Counter.UIKit.View {
	@objc func incrementButtonTapped() {
		increment()
	}

	@objc func decrementButtonTapped() {
		decrement()
	}
}

// MARK: -
extension Counter.UIKit.Screen: UpdatingScreen {
	// MARK: UpdatingScreen
	typealias View = Counter.UIKit.View
}
