# CHANGELOG

## Upcoming release

- Public models conform to Sendable protocol
- Move pass loading to a background thread when presenting a loyalty pass
- Ensure the capture session starts on a background thread when scanning QR codes

#### Breaking changes

- Ensure the loyalty pass `present` method is executed on the main thread by marking it with `MainActor`
- Crash reporting is deprecated and disabled by default. We recommend using another solution to collect crash analytics.
- Replaced protocol-based module implementations with top-level module class. As a result, delegate method implementations must remove the use of the 'any' keyword to align with the new concrete type.
