// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "Models",
	platforms: [
		.iOS(.v16)
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
