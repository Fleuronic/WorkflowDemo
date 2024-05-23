// Copyright © Fleuronic LLC. All rights reserved.

import UIKit
import Workflow
import WorkflowUI
import WorkflowContainers

import enum Counter.Counter

extension Counter.App {
	@UIApplicationMain final class Delegate: UIResponder {
		var window: UIWindow?
		
		@Environment(.demo) private var demo
	}
}

// MARK: -
extension Counter.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var workflow: AnyWorkflow<AnyScreen, Void> {
		Counter.Workflow(
			demo: demo,
			fromSource: false
		).mapRendering { item in
			BackStack.Screen(items: [item]).asAnyScreen()
		}
	}

	// MARK: UIApplicationDelegate
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		window = makeWindow()
		return true
	}
}
