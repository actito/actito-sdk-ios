# CHANGELOG

## 5.0.0-beta.1

- Align with Swift 6 and its Strict Concurrency requirements
- Most of the public implementation is now `@MainActor`-isolated
- Sendable data models
- Improved UI for iOS 26
- Improved network request retry mechanism
- Changed the default `presentationOptions` to `[.banner, .badge, .sound]`
- Offload PKPass loading to the background
- Crash reporting is deprecated and disabled by default. We recommend using another solution to collect crash analytics.

Prior to upgrading to v5.x, consult the [Migration Guide](./MIGRATION.md), which outlines all necessary changes and procedures to ensure a smooth migration.
