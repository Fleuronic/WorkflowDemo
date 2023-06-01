// Copyright © Fleuronic LLC. All rights reserved.

public protocol LoadingSpec {
    associatedtype DemoLoadingResult
    
    func loadDemos() async -> DemoLoadingResult
}
