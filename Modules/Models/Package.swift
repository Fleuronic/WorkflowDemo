// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "Models",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "Demo",
			targets: ["Demo"]
		)
	],
	dependencies: [],
	targets: [
		.target(
			name: "Demo",
			dependencies: []
		),
		.testTarget(
			name: "DemoTests",
			dependencies: ["Demo"]
		)
	]
)
