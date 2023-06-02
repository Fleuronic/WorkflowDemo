# WorkflowDemo

This project demonstrates how to use Square’s Workflow library to compose workflows that render screens that back the views in your application. It involves a simple counter app that leverages the same `Screen` and `Workflow` types to back identical looking UIs built using either SwiftUI, UIKit, or a hybrid “declarative UIKit” paradigm.

* [Layers](#layers)
* [Dependencies](#dependencies)
* [Declarative UIKit](#declarative-uikit)
* [Modules](#modularization)
* [Apps](#apps)
* [Test Coverage](#test-coverage)

## Layers

Applications built under this approach are best thought of having the layers **screen**, **view**, and **workflow** (SVW), as opposed to other layerings like MVC, MVVM, VIPER etc. All code in our application will fall  under one of (or be used by one or more of) these layers.

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

In other instances, the state may also include asynchronous workers, which have their own state and are typically can be started as the result of an action.

```swift
extension Counter {
    struct Workflow {}
}
```

We can define the workflow incrementally, first by conforming to the `Workflow` protocol. This requires that we provide an `Output` type: `Void` in this case, since we don't care what the workflow outputs upon completion, only that it has completed. It also needs an initial state and type, in this case the `Int` `0` (the initial value shown by the counter). Finally, it needs to know what to render given its current state and a render context. Here, this rendering is a `Counter.Screen` as defined above; the workflow uses its current state for the screen’s `value` property, and closures that send `Action`s (defined below) to a sink belonging to the workflow. A new rendering will be created, and hence the view backed by such a screen will be updated each time the workflow’s state updates.

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

Enums are a natural fit to define a workflow's possible actions:

```swift
extension Counter.Workflow {
    enum Action {
        case increment
        case decrement
        case finish
    }
}
```

They must conform to `WorkflowAction` by providing an associated `WorkflowType`, and a function that describes how one should update such a workflow’s state. This function is also responsible for returning an output if that action should complete the workflow, or `nil` if no such completion is triggered. In this example (not shown) a back button could trigger a `.finish` action which would output `()`; all other actions would have no output.

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

Ergo is a library that aims to simply Workflow and provides the UI-framework-specific libraries `ErgoSwiftUI` `ErgoUIKit`, and `ErgoDeclarativeUIKit`. Along with the main library, use the UI library/libraries that is/are appropriate for the UI framework(s) in your app. 

When using Workflow, the views that comprise your user interface depend on a `Screen` type. Depending on which UI framework you are using, this dependency is established in `Ergo` by conforming your view type to a protocol inheriting `ScreenBacked`.

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

In Declarative UIKit, your view will conform to `LayoutProvider`, and must return a Layoutless `Layout` type given a screen.


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

A `Worker` that has successfully completed its work and has successful output returns to the `.ready` state and reports its output back to the workflow in which it is running. A `Worker` can support either working to produce a singular `Output` when started with an `Input` (`(Input) -> AsyncStream<Output>`) or a continuous stream of `Output`s until it has finished (`(Input) -> AsyncStream<Output>`). Ergo uses `EnumKit` to facilitate access to this state.

### Inject

While SwiftUI boasts live previewing, no such functionality is found out of the box in UIKit. To compensate, this project demonstrates using Inject support live previewing of UIKit views. WHen Inject is running, saving any changes to UI code will immediately cause the running app to reflect those changes. While not necessary to run the demo app, it can make for a reliable way to quickly iterate on your app’s user interface, especially combined with the modularization techniques shown below.

### Test Dependencies

To exhaustively test all screen, workflow, and view code regardless of UI framework, this project makes use of swift-snapshot-testing, ViewInspector, and ErrorAssertions.

## Declarative UIKit

As described above, this project also demonstrates a reimagining of UIKit that uses similar declarative principles as SwiftUI. For example, a `Counter.View` built with Declarative UIKit as opposed to SwiftUI would be the following, and is shown within the demo app:

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

This makes use of `ErgoDeclarativeUIKit` and the Metric dependency, along with its Geometric and Telemetric submodules (in addition to Layoutless mentioned above). `ReactiveCocoa` and `ReactiveDataSources` powers much of the declarative interface to UIKit elements.

# Modularization

# Test Coverage
