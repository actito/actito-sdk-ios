# CHANGELOG

## Upcoming release

- Public models conform to Sendable protocol
- Move pass loading to a background thread when presenting a loyalty pass

#### Breaking changes

- Mark `present(notification: ActitoNotification, in viewController: UIViewController)` with `MainActor` to ensure main-thread execution
