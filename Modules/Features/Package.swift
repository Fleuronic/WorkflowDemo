// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "Features",
	platforms: [
		.iOS(.v15)
	],
	products: [
		.library(
			name: "Root",
			targets: ["Root"]
		),
		.library(
			name: "DemoList",
			targets: ["DemoList"]
		),
		.library(
			name: "Counter",
			targets: ["Counter"]
		)
	],
	dependencies: [
		.package(name: "Demo", path: "../Models"),
		.package(name: "DemoService", path: "../Services"),
		.package(url: "https://github.com/Fleuronic/ErgoSwiftUI", branch: "main"),
		.package(url: "https://github.com/Fleuronic/ErgoUIKit", branch: "main"),
		.package(url: "https://github.com/Fleuronic/ErgoDeclarativeUIKit", branch: "main"),
		.package(url: "https://github.com/Fleuronic/workflow-swift", branch: "main"),
		.package(url: "https://github.com/nalexn/ViewInspector", branch: "0.9.7"),
		.package(url: "https://github.com/SlaunchaMan/ErrorAssertions.git", from: "0.2.0")
	],
	targets: [
		.target(
			name: "Root",
			dependencies: [
				"DemoList",
				"Counter"
			]
		),
		.target(
			name: "DemoList",
			dependencies: [
				"Demo",
				"DemoService",
				"ErgoDeclarativeUIKit",
				.product(name: "WorkflowContainers", package: "workflow-swift")
			]
		),
		.target(
			name: "Counter",
			dependencies: [
				"Demo",
				"ErgoUIKit",
				"ErgoSwiftUI",
				"ErgoDeclarativeUIKit",
				.product(name: "WorkflowContainers", package: "workflow-swift"),
				.product(name: "ErrorAssertions", package: "ErrorAssertions")
			]
		),
		.testTarget(
			name: "RootTests",
			dependencies: [
				"Root",
				.product(name: "WorkflowTesting", package: "workflow-swift")
			]
		),
		.testTarget(
			name: "DemoListTests",
			dependencies: [
				"DemoList",
				.product(name: "WorkflowReactiveSwift", package: "workflow-swift"),
				.product(name: "WorkflowTesting", package: "workflow-swift"),
				.product(name: "ErgoDeclarativeUIKitTesting", package: "ErgoUIKit")
			]
		),
		.testTarget(
			name: "CounterTests",
			dependencies: [
				"Counter",
				"ViewInspector",
				.product(name: "WorkflowTesting", package: "workflow-swift"),
				.product(name: "ErgoSwiftUITesting", package: "ErgoSwiftUI"),
				.product(name: "ErgoUIKitTesting", package: "ErgoUIKit"),
				.product(name: "ErgoDeclarativeUIKitTesting", package: "ErgoUIKit"),
				.product(name: "ErrorAssertionExpectations", package: "ErrorAssertions")
			]
		)
	]
)
