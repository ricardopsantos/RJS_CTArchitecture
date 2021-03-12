# GoodToGo

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


## Public code 

* [roberthein/TinyConstraints](https://github.com/roberthein/TinyConstraints) for autolayouts.
* [scalessec/Toast-Swift](https://github.com/scalessec/Toast-Swift) for toast notifications.
* [ricardopsantos/RJSLibUF](https://github.com/ricardopsantos/RJSLibUF) is a personal library with utilies and extensions.

## General Specs


Preview 1 | Preview 2| Preview 3 | 
--- | --- | --- |
![Preview](Documents/preview.1.png) | ![Preview](Documents/preview.2.png) | ![Preview](Documents/preview.3.png) |

---

### Dependency graph

* __BaseUI__ : UI dependencies, VIP base classes, designables...
* __DevToos__ : Logs and developer utils.
* __Extensions__ : Generic extensions.
* __AppDomain__ : App values types and protocols.
* __BaseDomain__ : Generic app values types and protocols.
* __AppCore__ : App business. 
* __WebAPI__: WebAPI client.

When is rebuilt using [XcodeGen](https://ricardojpsantos.medium.com/avoiding-merge-conflicts-with-xcodegen-a0e2a1647bcb) using `./makefile.sh` just for fun, the dependency graph can be found at [__Documents/Graph.viz__](/Documents/Graph.viz) and visualized [__HERE__](https://dreampuf.github.io/GraphvizOnline)

After removing the SPM dependencies (RJPSLib, Toast, TinnyConstraints) from the graph, and also _DevTools_ and _Extensions_ (that both contains developer utils, and are know by all targets) we end up with:

 Xcode real dependency | Simplified dependency 
--- | --- 
![Preview](Documents/graph2.png) | ![Preview](Documents/graph1.png) 

### VIP


The project was build using the VIP arquitecture. See [__THIS__](https://github.com/ricardopsantos/RJPS_VIPCleanRx#project-modules-dependencies) repository for a quick intro.

Tip: the project start scene is _Scenes.ZipCodes_

![Preview](Documents/start.png)

---

### FRP

Instead of RxSwift (or others similar) is used Combine. (The less external dependencies on a project, the better)

---

### DataBase

CoreData and not Realm just to avoid another external dependency. 



 
# RJS_CTArchitecture
