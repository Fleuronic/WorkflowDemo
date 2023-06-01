// Copyright © Fleuronic LLC. All rights reserved.

import enum Demo.Demo
import protocol DemoService.LoadingSpec

extension API: LoadingSpec {
    public func loadDemos() async -> Demo.LoadingResult {
        do {
            try await sleep(.updateTime)
            return randomBool() ? .success(Demo.allCases) : .failure(.loadError)
        } catch {
            return .failure(.sleepError(error))
        }
    }
}

// MARK: -
public extension Demo {
    typealias LoadingResult = Swift.Result<[Demo], API.Error>
}

// MARK: -
private extension UInt64 {
    static let updateTime: Self = 500_000_000
}
