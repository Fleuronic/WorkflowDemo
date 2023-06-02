// Copyright © Fleuronic LLC. All rights reserved.

import UIKit
import Workflow
import WorkflowUI
import WorkflowContainers

import enum Demo.Demo
import enum DemoList.DemoList
import struct DemoAPI.API

extension DemoList.App {
	@UIApplicationMain
	final class Delegate: UIResponder {
		var window: UIWindow?

		@Environment(.canUpdateDemos) private var canUpdateDemos
		@Environment(.updateDuration) private var updateDuration
	}
}

// MARK: -
extension DemoList.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var workflow: AnyWorkflow<AnyScreen, Demo> {
		DemoList.Workflow(
			service: mockAPI,
			canSelectDemos: false
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

// MARK: -
private extension DemoList.App.Delegate {
	var mockAPI: MockDemoAPI {
		let canUpdateDemos = self.canUpdateDemos.map { $0 == "true" } ?? true
		let updateDuration = self.updateDuration.flatMap(TimeInterval.init) ?? 1

		return .init(
			duration: updateDuration,
			result: canUpdateDemos ? .success(Demo.allCases) : .failure(.loadError)
		)
	}
}
