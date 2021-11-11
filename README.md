---
typora-root-url: ./images
---

# SPMTools

A graphical tool for building and managing Xcode Swift Package Manager based on SwiftUI, which can be quickly added to the Chinese region, and it is convenient to use the Swift Package Manager faster through the terminal agent.

<img src="https://gitee.com/joser_zhang/upic/raw/master/uPic/image-20211111093350604.png" alt="image-20211111093350604" style="zoom:50%;" />

## Install

https://github.com/josercc/SPMTools/releases

## How To Use

In the first step, you must select the xcodeproj file as the data source

<img src="https://gitee.com/joser_zhang/upic/raw/master/uPic/image-20211111093642944.png" alt="image-20211111093642944" style="zoom:50%;" />

Then you can add, delete, edit and other operations for Swift Package Manager dependencies.

<img src="https://gitee.com/joser_zhang/upic/raw/master/uPic/image-20211111093740431.png" alt="image-20211111093740431" style="zoom:50%;" />

When all dependencies are ready, we can open the project terminal. Set up the proxy in advance, and then execute the following command to update the dependency.

```swift
xcodebuild -resolvePackageDependencies
```

If you find any problems during use, please return in time, thank you.
