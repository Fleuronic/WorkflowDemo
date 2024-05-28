// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "Services",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "DemoService",
			targets: [
				"DemoService",
				"DemoAPI"
			]
		)
	],
	dependencies: [
		.package(name: "Models", path: "../Models")
	],
	targets: [
		.target(
			name: "DemoService",
			dependencies: [
				.product(name: "Demo", package: "Models")
			],
			path: "Sources/Demo/Service"
		),
		.target(
			name: "DemoAPI",
			dependencies: ["DemoService"],
			path: "Sources/Demo/Clients/API"
		),
		.testTarget(
			name: "DemoAPITests",
			dependencies: ["DemoAPI"],
			path: "Tests/Demo/Clients/API"
		)
	]
)
