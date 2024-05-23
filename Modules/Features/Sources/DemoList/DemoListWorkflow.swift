// Copyright © Fleuronic LLC. All rights reserved.

import Ergo
import Workflow
import WorkflowUI
import WorkflowContainers
import DemoAPI

import enum Demo.Demo
import protocol DemoService.LoadingSpec

public extension DemoList {
	struct Workflow<Service: LoadingSpec> where Service.DemoLoadingResult == Demo.LoadingResult {
		private let service: Service
		private let canSelectDemos: Bool
		
		public init(service: Service) {
			self.init(
				service: service,
				canSelectDemos: true
			)
		}
		
		public init(
			service: Service,
			canSelectDemos: Bool
		) {
			self.service = service
			self.canSelectDemos = canSelectDemos
		}
	}
}

// MARK: -
extension DemoList.Workflow {
	enum Action: Equatable {
		case show([Demo]?)
		case demo(Demo)
		case updateDemos
	}
}

// MARK: -
extension DemoList.Workflow: Workflow {
	public typealias Output = Demo

	typealias UpdateWorker = Worker<Void, Demo.LoadingResult>

	public struct State {
		var demos: [Demo]
		let updateWorker: UpdateWorker
	}

	public func makeInitialState() -> State {
		let updateDemos = service.loadDemos
		return .init(
			demos: Demo.allCases,
			updateWorker: .ready(to: updateDemos)
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> BackStack.Item {
		context.render { (sink: Sink<Action>) in
			.init(
				screen: Alert.Screen(
					baseScreen: DemoList.Screen(
						demos: state.demos,
						selectDemo: { sink.send(.demo($0)) },
						canSelectDemo: { _ in canSelectDemos },
						isUpdatingDemos: state.isUpdatingDemos
					),
					alert: state.alert
				).asAnyScreen(),
				barContent: .init(
					title: "Workflow Demo",
					rightItem: .init(
						content: .text("Update"),
						isEnabled: !state.isUpdatingDemos,
						handler: { sink.send(.updateDemos) }
					)
				)
			)
		} running: {
			state.updateWorker.mapSuccess(Action.show)
		}
	}
}

// MARK: -
private extension DemoList.Workflow.State {
	var isUpdatingDemos: Bool {
		updateWorker.isWorking
	}

	var alert: Alert? {
		updateWorker.errorContext.map(makeAlert)
	}

	func makeAlert(
		error: Demo.LoadingResult.Failure,
		dismissHandler: @escaping () -> Void
	) -> Alert {
		let message = switch error {
		case .loadError:
			"The demos could not be updated. Please try again later."
		case let .sleepError(error):
			error.localizedDescription
		}
		
		return .init(
			title: "Update Error",
			message: message,
			actions: [
				.init(
					title: "Dismiss",
					handler: dismissHandler
				)
			]
		)
	}
}

// MARK: -
extension DemoList.Workflow.Action: WorkflowAction {
	public typealias WorkflowType = DemoList.Workflow<Service>

	public func apply(toState state: inout WorkflowType.State) -> Demo? {
		switch self {
		case let .show(demos?):
			state.demos = demos
		case let .demo(demo):
			return demo
		case .updateDemos:
			state.updateWorker.start()
		default:
			break
		}
		return nil
	}
}
