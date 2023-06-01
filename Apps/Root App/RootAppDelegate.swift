// Copyright © Fleuronic LLC. All rights reserved.

import UIKit
import Workflow
import WorkflowUI

import enum Root.Root
import struct DemoAPI.API

extension Root.App {
	@UIApplicationMain
	final class Delegate: UIResponder {
		var window: UIWindow?
	}
}

// MARK: -
extension Root.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var workflow: Root.Workflow<API> {
		.init(demoService: API())
	}

	// MARK: UIApplicationDelegate
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		window = makeWindow()
		return true
	}
}
