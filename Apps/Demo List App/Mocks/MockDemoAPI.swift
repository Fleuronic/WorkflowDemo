// Copyright © Fleuronic LLC. All rights reserved.

import Dispatch

import enum Demo.Demo
import struct Foundation.TimeInterval
import protocol DemoService.LoadingSpec

struct MockDemoAPI: LoadingSpec {
	let duration: TimeInterval
	let result: () -> Demo.LoadingResult

	init(
		duration: TimeInterval,
		result: @autoclosure @escaping () -> Demo.LoadingResult
	) {
		self.duration = duration
		self.result = result
	}
	
	func loadDemos() async -> Demo.LoadingResult {
		try! await Task.sleep(nanoseconds: UInt64(duration * TimeInterval(NSEC_PER_SEC)))
		return result()
	}
}
