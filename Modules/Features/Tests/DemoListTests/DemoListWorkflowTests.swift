// Copyright © Fleuronic LLC. All rights reserved.

import XCTest
import WorkflowTesting
import EnumKit

import enum Demo.Demo
import protocol DemoService.LoadingSpec

@testable import Ergo
@testable import WorkflowContainers
@testable import WorkflowReactiveSwift
@testable import enum DemoList.DemoList
@testable import struct WorkflowUI.AnyScreen

final class DemoListWorkflowTests: XCTestCase {
	func testDemo() {
		let demo = Demo.swiftUI
        
		DemoList.Workflow.Action.tester(
            withState: DemoList.Workflow(
                service: MockDemoAPI(
                    result: .success(Demo.allCases)
                )
            )
            .makeInitialState()
        )
		.send(action: .demo(demo))
		.assert(output: demo)
	}

    func testShowDemos() {
        let demos = Demo.allCases
        let api = MockDemoAPI(result: .success(demos))
        let updateDemos = api.loadDemos
        
        DemoList.Workflow.Action.tester(
            withState: DemoList.Workflow(
                service: api
            ).makeInitialState()
        )
        .send(action: .show(demos))
        .verifyState { XCTAssertEqual($0.demos, demos) }
        .assertNoOutput()
        
        DemoList.Workflow<MockDemoAPI>.Action.tester(
            withState: .init(
                demos: demos,
                updateWorker: .ready(to: updateDemos)
            )
        )
        .send(action: .show(nil))
        .verifyState { XCTAssertEqual($0.demos, demos) }
        .assertNoOutput()
    }
    
    func testUpdateDemos() {
        DemoList.Workflow.Action.tester(
            withState: DemoList.Workflow(
                service: MockDemoAPI(
                    result: .success(Demo.allCases)
                )
            ).makeInitialState()
        )
        .send(action: .updateDemos)
        .verifyState { XCTAssert($0.updateWorker.isWorking) }
        .assertNoOutput()
    }

	func testRenderingScreen() throws {
		let demos = Demo.allCases
        let canSelectDemo = true

		try DemoList.Workflow(
            service: MockDemoAPI(
                result: .success(demos)
            ),
            canSelectDemos: canSelectDemo
        )
		.renderTester()
		.expectWorkflow(
			type: WorkerWorkflow<DemoList.Workflow<MockDemoAPI>.UpdateWorker>.self,
			producingRendering: ()
		)
		.render { item in
			let alertScreen = try XCTUnwrap(item.screen.wrappedScreen as? Alert.Screen<DemoList.Screen>)
			let screen = alertScreen.baseScreen
			XCTAssertEqual(screen.demos, demos)
            
            for demo in demos {
                XCTAssertEqual(screen.canSelectDemo(demo), canSelectDemo)
            }

            let barContent = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
            XCTAssertEqual(barContent.title, "Workflow Demo")
		}
        .verifyState { state in
            XCTAssertEqual(state.demos, demos)
            XCTAssertTrue(state.updateWorker.isReady)
        }
	}

    func testRenderingUpdateDemos() throws {
        let api = MockDemoAPI(result: .success(Demo.allCases))
        let workflow = DemoList.Workflow(service: api)
        let updateDemos = api.loadDemos
        
        try workflow.renderTester().expectWorkflow(
            type: WorkerWorkflow<DemoList.Workflow<MockDemoAPI>.UpdateWorker>.self,
            producingRendering: ()
        )
        .render { item in
            let barContent = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
            let rightItem = try XCTUnwrap(barContent.rightItem)
            XCTAssertEqual(rightItem.content, .text("Update"))
            rightItem.handler()
        }
        .assert(action: DemoList.Workflow.Action.updateDemos)
        .assertNoOutput()
        
        try workflow.renderTester(
            initialState: .init(
                demos: Demo.allCases,
                updateWorker: .working(to: updateDemos)
            )
        )
        .expectWorkflow(
            type: WorkerWorkflow<DemoList.Workflow<MockDemoAPI>.UpdateWorker>.self,
            producingRendering: ()
        )
        .render { item in
            let barContent = try XCTUnwrap(item.barVisibility[expecting: Bar.Content.self])
            let rightItem = try XCTUnwrap(barContent.rightItem)
            XCTAssertFalse(rightItem.isEnabled)
        }
        .assertNoOutput()
    }

	func testRenderingSelectDemo() throws {
		let demo = Demo.swiftUI

		try DemoList.Workflow(
            service: MockDemoAPI(
                result: .success(Demo.allCases)
            )
        )
		.renderTester()
		.expectWorkflow(
			type: WorkerWorkflow<DemoList.Workflow<MockDemoAPI>.UpdateWorker>.self,
			producingRendering: ()
		)
		.render { backStackScreen in
			let wrappedScreen = backStackScreen.screen.wrappedScreen
			let alertScreen = try XCTUnwrap(wrappedScreen as? Alert.Screen<DemoList.Screen>)
			let demoListScreen = alertScreen.baseScreen
			demoListScreen.selectDemo(demo)
		}
		.assert(action: DemoList.Workflow.Action.demo(demo))
		.assert(output: demo)
	}
    
    func testRenderingCanSelectDemo() throws {
        let demo = Demo.swiftUI

        try DemoList.Workflow(
            service: MockDemoAPI(
                result: .success(Demo.allCases)
            )
        )
        .renderTester()
        .expectWorkflow(
            type: WorkerWorkflow<DemoList.Workflow<MockDemoAPI>.UpdateWorker>.self,
            producingRendering: ()
        )
        .render { backStackScreen in
            let wrappedScreen = backStackScreen.screen.wrappedScreen
            let alertScreen = try XCTUnwrap(wrappedScreen as? Alert.Screen<DemoList.Screen>)
            let demoListScreen = alertScreen.baseScreen
            demoListScreen.selectDemo(demo)
        }
        .assert(action: DemoList.Workflow.Action.demo(demo))
        .assert(output: demo)
    }

    func testRenderingAlertLoadError() throws {
        let error = Demo.LoadingResult.Error.loadError
        let api = MockDemoAPI(result: .failure(error))
        let updateDemos = api.loadDemos

        try DemoList.Workflow(service: api) .renderTester(
            initialState: .init(
                demos: Demo.allCases,
                updateWorker: .init(
                    state: .failed(error),
                    return: updateDemos
                )
            )
        )
        .expectWorkflow(
            type: WorkerWorkflow<DemoList.Workflow<MockDemoAPI>.UpdateWorker>.self,
            producingRendering: ()
        )
        .render { backStackScreen in
            let wrappedScreen = backStackScreen.screen.wrappedScreen
            let alertScreen = try XCTUnwrap(wrappedScreen as? Alert.Screen<DemoList.Screen>)
            let alert = try XCTUnwrap(alertScreen.alert)
            XCTAssertEqual(alert.title, "Update Error")
            XCTAssertEqual(alert.message, "The demos could not be updated. Please try again later.")
            
            let dismissAction = try XCTUnwrap(alert.actions.first)
            XCTAssertEqual(dismissAction.title, "Dismiss")
            dismissAction.handler()
        }
        .verifyState { XCTAssert($0.updateWorker.isReady) }
        .assertNoAction()
        .assertNoOutput()
    }
    
    func testRenderingAlertSleepError() throws {
        let sleepErrorMessage = "Unable to sleep — have you tried less caffeine?"
        let underlyingError = NSError(
            domain: "DemoAPI.API.Error",
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey: sleepErrorMessage
            ]
        )

        let error = Demo.LoadingResult.Error.sleepError(underlyingError)
        let api = MockDemoAPI(result: .failure(error))
        let updateDemos = api.loadDemos

        try DemoList.Workflow(service: api) .renderTester(
            initialState: .init(
                demos: Demo.allCases,
                updateWorker: .init(
                    state: .failed(error),
                    return: updateDemos
                )
            )
        )
        .expectWorkflow(
            type: WorkerWorkflow<DemoList.Workflow<MockDemoAPI>.UpdateWorker>.self,
            producingRendering: ()
        )
        .render { backStackScreen in
            let wrappedScreen = backStackScreen.screen.wrappedScreen
            let alertScreen = try XCTUnwrap(wrappedScreen as? Alert.Screen<DemoList.Screen>)
            let alert = try XCTUnwrap(alertScreen.alert)
            XCTAssertEqual(alert.title, "Update Error")
            XCTAssertEqual(alert.message, sleepErrorMessage)
            
            let dismissAction = try XCTUnwrap(alert.actions.first)
            XCTAssertEqual(dismissAction.title, "Dismiss")
            dismissAction.handler()
        }
        .verifyState { XCTAssert($0.updateWorker.isReady) }
        .assertNoAction()
        .assertNoOutput()
    }
    
    func testUpdateWorkerSuccess() throws {
        let result = Demo.LoadingResult.success(Demo.allCases)
        let api = MockDemoAPI(result: result)
        let updateDemos = api.loadDemos
        let expectation = expectation(description: "UpdateDemos")
        let worker = DemoList.Workflow<MockDemoAPI>.UpdateWorker.working(to: updateDemos)
        
        worker.run().startWithValues { result in
            switch result {
            case .success(Demo.allCases):
                expectation.fulfill()
            default:
                break
            }
        }
        
        wait(for: [expectation])
    }
    
    func testUpdateWorkerFailureLoadError() throws {
        let result = Demo.LoadingResult.failure(.loadError)
        let api = MockDemoAPI(result: result)
        let updateDemos = api.loadDemos
        let expectation = expectation(description: "UpdateDemos")
        let worker = DemoList.Workflow<MockDemoAPI>.UpdateWorker.working(to: updateDemos)
        
        worker.run().startWithValues { result in
            switch result {
            case .failure(.loadError):
                expectation.fulfill()
            default:
                break
            }
        }
        
        wait(for: [expectation])
    }
    
    func testUpdateWorkerFailureSleepError() throws {
        let result = Demo.LoadingResult.failure(.sleepError(NSError()))
        let api = MockDemoAPI(result: result)
        let updateDemos = api.loadDemos
        let expectation = expectation(description: "UpdateDemos")
        let worker = DemoList.Workflow<MockDemoAPI>.UpdateWorker.working(to: updateDemos)

        worker.run().startWithValues { value in
            switch value {
            case result:
                expectation.fulfill()
            default:
                break
            }
        }
        
        wait(for: [expectation])
    }
}

// MARK: -
extension Bar.Visibility: CaseAccessible {}

// MARK: -
private struct MockDemoAPI: LoadingSpec {
    let result: Demo.LoadingResult
    
    func loadDemos() async -> Demo.LoadingResult { result }
}
