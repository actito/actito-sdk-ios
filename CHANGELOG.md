# CHANGELOG

## Upcoming release

- Public models conform to Sendable protocol
- Move pass loading to a background thread when presenting a loyalty pass

#### Breaking changes

- Ensure the loyalty pass `present` method is executed on the main thread by marking it with `MainActor`
- Crash reporting is deprecated and disabled by default. We recommend using another solution to collect crash analytics.
