# RJS_CTArchitecture

__These are my notes on The__ [__Composable Architecture__](https://github.com/pointfreeco/swift-composable-architecture)

---

<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat" alt="Swift 5.3">
   </a>
    <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Xcode-12.0.1-blue.svg" alt="Swift 5.3">
   </a>
   <a href="">
      <img src="https://img.shields.io/cocoapods/p/ValidatedPropertyKit.svg?style=flat" alt="Platform">
   </a>
   <br/>
   <a href="https://twitter.com/ricardo_psantos/">
      <img src="https://img.shields.io/badge/Twitter-@ricardo_psantos-blue.svg?style=flat" alt="Twitter">
   </a>
</p>


## Install

No need to install anything, since the dependencie manager is SPM.

However, the project can all be rebuilt with `./makefile.sh` (for a total clean up of conflits fixing) using [XcodeGen](https://ricardojpsantos.medium.com/avoiding-merge-conflicts-with-xcodegen-a0e2a1647bcb).

![Preview](Documents/install.1.png)

## About

![Preview](Documents/preview.1.png)

This project contain 2 simple apps, both with incrementat versions (v1, v2, v3...) and and also previews on each version.

---

__`Scenes.PrimeApp`__ is my walkthrough app on:

* [SwiftUI and State Management: Part 1](https://www.pointfree.co/collections/composable-architecture/swiftui-and-state-management/ep65-swiftui-and-state-management-part-1)

* [SwiftUI and State Management: Part 2](https://www.pointfree.co/collections/composable-architecture/swiftui-and-state-management/ep66-swiftui-and-state-management-part-2)

* [SwiftUI and State Management: Part 3](https://www.pointfree.co/collections/composable-architecture/swiftui-and-state-management/ep66-swiftui-and-state-management-part-3)

* [Composable State Management: Reducers](https://www.pointfree.co/collections/composable-architecture/swiftui-and-state-management/ep65-swiftui-and-state-management-part-1)

__Code:__

* `Prime_V1.swift`
* `Prime_V2.swift`
* `Prime_V3.swift`

--

__`Scenes.TodoApp`__ is my walkthrough app on:

* [A Tour of the Composable Architecture: Part 1](https://www.pointfree.co/collections/composable-architecture/a-tour-of-the-composable-architecture/ep100-a-tour-of-the-composable-architecture-part-1)
  * `Todo_V1.ContentView.swift`
  * `Todo_V2.ContentView.swift`

* [A Tour of the Composable Architecture: Part 2](https://www.pointfree.co/collections/composable-architecture/a-tour-of-the-composable-architecture/ep100-a-tour-of-the-composable-architecture-part-2)
  * `Todo_V3.ContentView.swift`
  * `Todo_V4.ContentView.swift`
  * `Todo_V5.ContentView.swift`

* [A Tour of the Composable Architecture: Part 3](https://www.pointfree.co/collections/composable-architecture/a-tour-of-the-composable-architecture/ep100-a-tour-of-the-composable-architecture-part-3)
  * `Todo_V6.ContentView.swift`
  * `Todo_V7.ContentView.swift`
  
  * [A Tour of the Composable Architecture: Part 4](https://www.pointfree.co/collections/composable-architecture/a-tour-of-the-composable-architecture/ep100-a-tour-of-the-composable-architecture-part-4)
    * `Todo_V8.ContentView.swift`
    
(in progress)


## Personal notes

### Intro

[__More__](https://github.com/pointfreeco/swift-composable-architecture#basic-usage)

* __State__: A type that describes the data your feature needs to perform its logic and render its UI.
Action: A type that represents all of the actions that can happen in your feature, such as user actions, notifications, event sources and more.

* __Environment__: A type that holds any dependencies the feature needs, such as API clients, analytics clients, etc.

* __Reducer__: A function that describes how to evolve the current state of the app to the next state given an action. The reducer is also responsible for returning any effects that should be run, such as API requests, which can be done by returning an Effect value.

* __Store__: The runtime that actually drives your feature. You send all user actions to the store so that the store can run the reducer and effects, and you can observe state changes in the store so that you can update UI.

### Misc

* Each view powered by TCA have a (generic) store (over the state)

* All the pure logic happens on the __State__ mutations

* All tne non pure logic happens on the __Effects__

* The __Reducer__ powers the BUSINESS logic

* The __Reducer__ returns an __Effect__ (or more). Returns `[.none]` if there are no side efects

* The AppEnvironment gives the dependencies

* AppState must conforme to `Equatable` to avoid duplications of state on `WithViewStore(self.store)...``

* __Reducers__ are the glue that bind together __State__, __Actions__, and __Effects__
