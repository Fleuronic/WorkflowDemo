// Copyright © Fleuronic LLC. All rights reserved.

public struct API {
    let sleep: Sleep
    let randomBool: () -> Bool
    
    public init() {
        self.init(
            sleep: Task.sleep(nanoseconds:),
            randomBool: Bool.random
        )
    }

    init(
        sleep: @escaping Sleep,
        randomBool: @escaping () -> Bool
    ) {
        self.sleep = sleep
        self.randomBool = randomBool
    }
}

// MARK: -
extension API {
    typealias Sleep = (UInt64) async throws -> Void
}
