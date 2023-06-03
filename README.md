# Workflow Demo

This project demonstrates how to use Square’s [Workflow](https://github.com/square/workflow-swift) library to compose workflows that render screens that back the views in your application. It involves a simple counter app that leverages the same `Screen` and `Workflow` types to back identical looking UIs built using either SwiftUI, UIKit, or a hybrid “declarative UIKit” paradigm.

* [Layers](#layers)
* [Dependencies](#dependencies)
* [Declarative UIKit](#declarative-uikit-section)
* [Modules](#modules)
* [Apps](#apps)
* [Test Coverage](#test-coverage)

## Layers

Applications built under this approach are best thought of as having the layers **screen**, **view**, and **workflow** (SVW), as opposed to other layerings like MVC, MVVM, VIPER etc. All code in our application will fall under one of (or be used by one or more of) these layers.

### Screen

Using the counter example, we start with a `Counter.Screen` struct that describes how the user sees and interacts with the application when the counter is displayed.

```swift
extension Counter {
    struct Screen {
        let value: Int
        let increment: () -> Void
        let decrement: () -> Void
    }
}

extension Counter.Screen {
    var valueText: String { "The value is \(value)" }
    var incrementTitle: String { "+" }
    var decrementTitle: String { "-" }
}
```

This screen will back a view that uses these values to know both what to display, and what to do upon user interaction. It will display the current `value`, execute the `increment` closure when the increment button is tapped, and execute the `decrement` closure when the decrement button is tapped. As a result, thanks to a *workflow*, a new value of `Counter.Screen` will be passed into the view, with the updated `value`, as described later.

### View

A `Counter.View`, in this example built with SwiftUI, is dependent on a `Counter.Screen` in order to derive its body.

```swift
extension Counter {
    struct View {
        init() {}
    }
}

extension Counter.View: BodyProvider {
    typealias Screen = Counter.Screen

    func body(with screen: Screen) -> some View {
        VStack {
            Text(screen.valueText)
            Button(action: screen.increment) {
                Text(screen.incrementTitle)
            }
            Button(action: screen.decrement) {
                Text(screen.decrementTitle)
            }
        }
    }
}

extension Counter.Screen: BodyBackingScreen {
    typealias View = Counter.View
}
```

The resulting view has a body of a simple `VStack` with `Text` and two `Button`s. Notice that `Counter.View` declares an explicit dependency on `Counter.Screen`, and in fact derives its entire body based on the properties of the screen. The reverse relationship must also be explicitly declared. All that is left is to define a workflow that renders this screen based on a state, constructing it such that actions performed will update this state and cause a new screen to be rendered.

### Workflow

Finally, the `Counter.Workflow` type defines
* An internal state with an initial value
* How and what to render by constructing a screen based on that state
* Actions that can be performed as the result of user interaction with that rendering
* How to update its internal state given an action
* What to output upon an action that completes the workflow

(In many cases, the state may also include asynchronous workers, which have their own state and are typically can be started as the result of an action.)

```swift
extension Counter {
    struct Workflow {}
}
```

We can define the workflow incrementally, first by conforming to the `Workflow` protocol. This requires that we provide an `Output` type: `Void` in this case, since we don't care what the workflow outputs upon completion, only that it has completed.

It also needs an initial state and type, in this case the `Int` `0` (the initial value shown by the counter).

Finally, it needs to know what to render given its current state and a render context. Here, this rendering is a `Counter.Screen` as defined above; the workflow uses its current state for the screen’s `value` property, and closures that send `Action`s (defined below) to a sink belonging to the workflow. A new rendering will be created, and hence the view backed by such a screen will be updated each time the workflow’s state updates.

```swift
extension Counter.Workflow: Workflow {
    typealias Output = Void

    func makeInitialState() -> Int { 0 }

    func render(
        state value: Int, 
        context: RenderContext<Self>
    ) -> Counter.Screen {
        context.render { (sink: Sink<Action>) in
            .init(
                value: value,
                increment: { sink.send(.increment) },
                decrement: { sink.send(.decrement) }
            )
        }
    }
}
```

#### Workflow Actions

Enums are a natural fit to define a workflow’s possible actions:

```swift
extension Counter.Workflow {
    enum Action {
        case increment
        case decrement
        case finish
    }
}
```

They must conform to `WorkflowAction` by providing our workflow’s type as an associated `WorkflowType`, and a function that describes how one should update such a workflow’s state. This function is also responsible for returning an output if that action should complete the workflow, or `nil` if no such completion is triggered. In this example (not shown) a back button could trigger a `finish` action which would output `()`; all other actions would have no output.

```swift
extension Counter.Workflow.Action: WorkflowAction {
    typealias WorkflowType = Counter.Workflow

    func apply(toState value: inout Int) -> Void? {
        switch self {
        case .increment:
            value += 1
        case .decrement:
            value -= 1
        case .finish:
            return ()
        }
        return nil
    }
}
```

## Dependencies

While Workflow can be used out of the box without any of this project’s own dependencies, I’ve had the best experience using the techniques shown here, especially when it comes to defining the view layer. 

### Ergo

[Ergo](https://github.com/Fleuronic/Ergo) is a library that aims to simplify Workflow and provides the UI-framework-specific libraries `ErgoSwiftUI` `ErgoUIKit`, and `ErgoDeclarativeUIKit`. Along with the main library, use the UI library/libraries that is/are appropriate for the UI framework(s) in your app. 

When using Workflow, the views that comprise your user interface depend on a `Screen` type. Depending on which UI framework you are using, this dependency is established in Ergo by conforming your view type to a protocol inheriting `ScreenBacked`.

```swift
protocol ScreenBacked {
    associatedtype Screen: WorkflowUI.Screen
}
```

#### SwiftUI

In SwiftUI, your view will conform to `BodyProvider`, and must return a SwiftUI `View` as its body given a screen.

```swift
protocol BodyProvider: ScreenBacked {
    associatedtype Body: View

    init()

    func body(with screen: Screen) -> Body
}
```

#### UIKit

In UIKit, your view will conform to `Updating`, and must indicate how it should be initialized and updated with a screen.


```swift
protocol Updating: ScreenBacked {
    init(screen: Screen)

    func update(with screen: Screen)
}
```

#### Declarative UIKit

In Declarative UIKit, your view will conform to `LayoutProvider`, and must return a [Layoutless](https://github.com/DeclarativeHub/Layoutless) `Layout` type given a screen. See more on Declarative UIKit below.


```swift
protocol LayoutProvider: ScreenBacked {
    func layout(with screen: some ScreenProxy<Screen>) -> AnyLayout
}
```

You can see examples of all three conformances in Workflow Demo’s `CounterSwiftUIView`, `CounterUIKitView`, and `CounterDeclarativeUIKitView`, respectively.

#### Workers

Ergo also provides its own `Worker` class to represent asynchronous work your application needs to perform. A `Worker` is generic over `Input` and `Output` and can be in one of three states:

```swift
enum State: CaseAccessible {
    case ready
    case working(Input)
    case failed(Output.Failure)
}
```

A `Worker` that has successfully completed its work and has successful output returns to the `ready` state and reports its output back to the workflow in which it is running. A `Worker` can support either working to produce a singular `Output` when started with an `Input` (`(Input) -> async Output`) or a continuous stream of `Output`s until it has finished (`(Input) -> AsyncStream<Output>`). Ergo uses [EnumKit](https://github.com/gringoireDM/EnumKit) to facilitate access to this state.

As an example, consider a worker in a `DemoList.Workflow` that works to update the list of demos shown. This workflow’s state would contain a `Worker<Void, Result<[Demo], Error>>` called  e.g. `updateWorker`. It requires no input to start updating the list, and outputs either an array of demos (if it succeeds) or an error (if it fails). An example implementation of this workflow’s `Action`’s `apply` method would be responsible for starting this worker from the `updateDemos` action. 

```swift
case .updateDemos:
    state.updateWorker.start()
```

We’ll send this action when the user taps the navigation bar’s right bar button item. The worker must also be referenced in the workflow’s render function, along with the action to send if it succeeds. In this case, if the worker is successful, we should dispatch the `show` action to show the successfully loaded demos.

```swift
func render(
    state: State,
    context: RenderContext<Self>
) -> BackStack.Item {
    context.render { (sink: Sink<Action>) in
        .init(
            screen: DemoList.Screen(
                demos: state.demos,
                selectDemo: { sink.send(.demo($0)) },
                canSelectDemo: { _ in canSelectDemos },
                isUpdatingDemos: state.updateWorker.isWorking
            ).asAnyScreen(),
            barContent: .init(
                rightItem: .init(
                    content: .text("Update"),
                    handler: { sink.send(.updateDemos) }
                )
            )
        )
    } running: {
        state.updateWorker.mapSuccess(Action.show)
    }
}
```

Now, all our `Action`’s `apply` function has to do is update the state with demos returned in the `show` action:

```swift
case let .show(demos):
    state.demos = demos
```

### Inject

While SwiftUI boasts live previewing (“hot reloading”), no such functionality is found out of the box in UIKit. To compensate, this project demonstrates using [Inject](https://github.com/krzysztofzablocki/Inject) to support live previewing of UIKit views. When Inject is running, saving any changes to UI code will immediately cause the running app to reflect those changes. While not necessary to run the demo app, it can make for a reliable way to quickly iterate on your app’s user interface, especially combined with the modularization techniques shown below.

### Test Dependencies

To exhaustively test all screen, workflow, and view code regardless of UI framework, this project makes use of [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing), [ViewInspector](https://github.com/nalexn/ViewInspector), and [ErrorAssertions](https://github.com/SlaunchaMan/ErrorAssertions).

<a name="declarative-uikit-section"></a>
## Declarative UIKit

As described above, this project also demonstrates a reimagining of UIKit that uses similar declarative principles as SwiftUI. For example, a `Counter.View` built with Declarative UIKit as opposed to SwiftUI would be implemented as follows, and is shown within the demo app:

```swift
extension Counter {
    final class View: UIView {}
}

extension Counter.View: LayoutProvider {
    typealias Screen = Counter.Screen

    func layout(with screen: some ScreenProxy<Screen>) -> AnyLayout {
        UIStackView.vertical.layout {
            UILabel.default
                .text(screen.valueText)
            UIButton.default
                .title(screen.incrementTitle)
                .tapped(screen.increment)
            UIButton.default
                .title(screen.decrementTitle)
                .tapped(screen.decrement)
        }.centeringInParent()
    }
}

extension Counter.Screen: LayoutBackingScreen {
    typealias View = Counter.View
}
```

Refer also to the demo list view, which is implemented solely in Declarative UIKit. This choice provided a more concise and readable definition than even the SwiftUI equivalent.

```swift
extension DemoList {
    final class View: UIView {}
}

extension DemoList.View: LayoutProvider {
    typealias Screen = DemoList.Screen

    func layout(with screen: some ScreenProxy<Screen>) -> AnyLayout {
        UITableView.style(.insetGrouped).content(
            items: screen.demos,
            text: \.name,
            loading: screen.isUpdatingDemos,
            canSelectItem: screen.canSelectDemo.value
        ).itemSelected(screen.selectDemo).fillingParent()
    }
}

extension DemoList.Screen: LayoutBackingScreen {
    typealias View = DemoList.View
}
```

As defined above, the view consists of an inset grouped table view that displays rows with the names of the screen’s demos, or a row with a spinner if the screen is updating the demos. If a demo is selected (when possible as determined by the screen), the screen’s `selectDemo` closure is executed.

These views make use of `ErgoDeclarativeUIKit` and the [Metric](https://github.com/Fleuronic/Metric) dependency—along with its [Geometric](https://github.com/Fleuronic/Geometric) and [Telemetric](https://github.com/Fleuronic/Telemetric) submodules—in addition to Layoutless mentioned above. [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) and [ReactiveDataSources](https://github.com/Fleuronic/ReactiveDataSources) power much of the declarative interface to UIKit elements.

## Modules

This project follows a modular architecture with a clear separation of concerns. Central to its  structure is the top-level `Modules` directory, which itself is subdivided into the `Models`, `Services`, and `Features` modules. Each feature module has an associated app used to showcase that feature in isolation. The full application, then, is simply the `Root` feature’s app. Crucially, the `Root` feature’s child features, `DemoList` and `Counter`, have no knowledge of each other and, as their respective apps show, can exist in isolation—it is the responsibility of the parent feature, and only the parent feature, to detemermine the interaction between its child features.

### Models

#### Demo

Our simple app relies on a single model type, representing one of the three demos it is capable of showing.

```swift
enum Demo: Hashable {
    case swiftUI
    case uiKit(declarative: Bool)
}
```

### Services

#### DemoService

A service that simulates loading demos from a network. It provides a single spec, `LoadingSpec`, that clients can adopt.

```swift
protocol LoadingSpec {
    associatedtype DemoLoadingResult

    func loadDemos() async -> DemoLoadingResult
}
```

#### DemoAPI

The main client provided in `DemoAPI` simply sleeps for a given time, then either randomly returns the demos, or fails.

```swift
extension API: LoadingSpec {
    func loadDemos() async -> Demo.LoadingResult {
        do {
            try await sleep(.updateTime)
            return randomBool() ? .success(Demo.allCases) : .failure(.loadError)
        } catch {
             return .failure(.sleepError(error))
        }
    }
}
```
 
For testing purposes, the `sleep` and `randomBool` closures can be injected upon initialization. 

### Features

#### Root

The root feature of the application, which synthesizes the `DemoList` and `Counter` features. Under this feature, selecting a demo in the `DemoList` feature will start the demo in the `Counter` feature. When the user is finished interacting with the demo, `Root` returns the user to the `DemoList` feature.

#### DemoList

A feature that displays a list of `Demo`s, which can be “updated” using the `DemoService`.

#### Counter

A feature (described above) that shows a number value which can be incremented and decremented.

## Apps

Each feature module has a corresponding app to showcase its functionality. To run an app, simply select the associated scheme and invoke Product > Run. To set an environment variable, edit the scheme and select the Arguments tab under Run. All relevant environment variables for each app are already added, but can be disabled or updated.

### RootApp

Displayed as “Workflow Demo”, **this is our “application.”** Users are presented with a list of three demos: SwiftUI, UIKit, and Declarative UIKit. This list can be updated. Selecting an item in the list will start a counter demo built with the associated UI framework. The back button then returns the user to the list of demos. 

### DemoListApp

An app to showcase the `DemoList` feature in isolation. As a result, the demos are not selectable, and their rows display no disclosure indicator. Users can however tap “Update” in the navigation bar to reload the list, which may fail.

#### Environment Variables

- `canUpdateDemos`: Whether updating the demos succeeds. Optional, defaults to `true`.
- `updateDuration`: How long in seconds it takes to update the demos. Optional, defaults to 1.

### CounterApp

An app to showcase the `Counter` feature in isolation. As such, we are not coming from a `DemoList` in this app, so the type of demo shown is indicated by an environment variable.

#### Environment Variables

- `demo`: The demo to launch into. One of `swiftUI`, `uiKit`, or `declarativeUIKit`. Required.

## Test Coverage

Each module in this project comes with full unit test coverage. The developer can fully test a module by selecting its scheme and running the associated test plan. Feature modules provide unit tests for their screen, view, and workflow layers. Outside of the modules themselves, integration tests and snapshot tests are provided at the project level, and UI tests are provided for each app. See [Square’s tutorial](https://github.com/square/workflow-swift/blob/main/Samples/Tutorial/Tutorial5.md) to learn how to write unit tests and integration tests for your workflows and their actions.
