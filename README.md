# Restorable Countdown

![](https://github.com/JonnyBeeGod/RestorableCountdown/workflows/Swift/badge.svg)
[![codecov](https://codecov.io/gh/JonnyBeeGod/RestorableCountdown/branch/master/graph/badge.svg?token=y21zGNAsLL)](https://codecov.io/gh/JonnyBeeGod/RestorableCountdown)
<img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
<a href="https://swift.org/package-manager">
    <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
</a>
<img src="https://img.shields.io/badge/platforms-iOS+macOS+tvOS+watchOS-brightgreen.svg?style=flat" alt="Mac + Linux" />
<a href="https://twitter.com/jonezdotcom">
    <img src="https://img.shields.io/badge/twitter-@jonezdotcom-blue.svg?style=flat" alt="Twitter: @jonezdotcom" />
</a>

Restorable Countdown is a convenient framework for managing long running countdowns written in Swift for Cocoa. 

# What does it do?
Restorable Countdown allows for managing very long running timers and countdowns. It is a wrapper around Swift Foundations `Timer` class and gracefully saves and restores its state when the application goes into background by hooking in the `UApplicationDelegate` / `NSApplicationDelegate` lifecycle methods. Restorable Countdown is compatible with all four relevant platforms iOS / iPadOS, macOS, tvOS and watchOS. It also supports sending local notifications on completion. 

# How to install?
Restorable Countdown is compatible with Swift Package Manager. To install, simply add this repository URL to your swift packages as package dependency in Xcode. 
Alternatively, add this line to your `Package.swift` file:

```
dependencies: [
    .package(url: "https://github.com/JonnyBeeGod/RestorableCountdown", from: "0.1.0")
]
```

And don't forget to add the dependency to your target(s). 

# How to use?
1. Initialize a `CountdownConfiguration` and configure it to your needs. As a start you can also use the predefined values and go from here.
2. Create a `Countdown` object and feed it the configuration from step 1 and a `CountdownDelegate`
3. Call `startCountdown()` 

## Notifications
Inject a `UNUserNotificationCenter` as well as a `UNUserNotificationContent` object on initialization if you want to schedule a local notification when the countdown has finished. Make sure that you have asked for user permissions before, see [here](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications).

# Caveats
- [ ] Currently no background execution supported meaning that the countdown will stop firing and executing code as soon as the app is in the background. When the app goes into foreground again the timer resumes and / or finishes. 

The reason for this is that the options we get from Apple for executing code in the background are very limited and have gotten even more restrictive in the past. I was previously using means to extend background execution time as described [here](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background/extending_your_app_s_background_execution_time), but discovered that this is not a solution for very long running timers over a couple of minutes. Modes for background execution might be added later but will probably only be possible with some limitations as or the reasons described above. 
