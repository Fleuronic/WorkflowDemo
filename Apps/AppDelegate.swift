// Copyright © Fleuronic LLC. All rights reserved.

import UIKit
import Workflow
import WorkflowUI

protocol AppDelegate: UIApplicationDelegate {
	associatedtype Workflow: AnyWorkflowConvertible where Workflow.Rendering: Screen

	var workflow: Workflow { get async }
}

// MARK: -
extension AppDelegate {
	func makeWindow() -> UIWindow {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.makeKeyAndVisible()
		window.rootViewController = .init()
		
		Task {
			let workflow = await self.workflow
			await MainActor.run {
				window.rootViewController = WorkflowHostingController(workflow: workflow)
			}
		}
		
		return window
	}
}
