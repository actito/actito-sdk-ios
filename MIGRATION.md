# MIGRATING

Actito 5.x is a complete rebranding of the Notificare SDK. Most of the migration involves updating the implementation from Notificare to Actito while keeping the original method invocations.

Additionally, this release aligns the SDK with **Swift 6** and its **Strict Concurrency** model.
This change may have a greater impact on older projects, whereas newer applications that are already `@MainActor`-based will require little to no adjustment.

## Deprecations

- Crash reporting is now deprecated and disabled by default. In case you have explicitly opted in, consider removing `CRASH_REPORTING_ENABLED` from your `ActitoOptions.plist`. We recommend using another solution to collect crash analytics.

## Breaking changes

### Removals

- Removed Scannables module.

### Dependencies

#### Swift Package Manager (SPM)

Open your project’s **Package Dependencies** settings, remove the Notificare package, and add the new Actito package instead:

```
https://github.com/actito/actito-sdk-ios.git
```

Make sure to only add the libraries you need to your targets.

#### CocoaPods

Open your project’s **Podfile**, remove the Notificare dependencies, and add the new Actito dependencies instead:

Make sure to include only those you are already using.

```diff
# Required
-pod 'Notificare/NotificareKit'

# Optional modules
-pod 'Notificare/NotificareAssetsKit'
-pod 'Notificare/NotificareGeoKit'
-pod 'Notificare/NotificareInAppMessagingKit'
-pod 'Notificare/NotificareInboxKit'
-pod 'Notificare/NotificareLoyaltyKit'
-pod 'Notificare/NotificarePushKit'
-pod 'Notificare/NotificarePushUIKit'
-pod 'Notificare/NotificareScannablesKit'
-pod 'Notificare/NotificareUserInboxKit'

# Required
+pod 'Actito/ActitoKit'

# Optional modules
+pod 'Actito/ActitoAssetsKit'
+pod 'Actito/ActitoGeoKit'
+pod 'Actito/ActitoInAppMessagingKit'
+pod 'Actito/ActitoInboxKit'
+pod 'Actito/ActitoLoyaltyKit'
+pod 'Actito/ActitoPushKit'
+pod 'Actito/ActitoPushUIKit'
+pod 'Actito/ActitoUserInboxKit'
```

### Configuration and options files

- If your project uses the **managed configuration** approach — meaning it includes a `NotificareServices.plist` file, you must rename this file to `ActitoServices.plist`.
- Rename `NotificareOptions.plist` to `ActitoOptions.plist`.

### Implementation

The SDK is now built with **Swift 6** and fully adopts its **Strict Concurrency** model.
Most of the implementation is @MainActor-isolated to guarantee thread safety, while background operations — such as network requests — are automatically executed outside the main actor to maintain optimal performance.

#### Rename references

You must update all references to the old Notificare classes and packages throughout your project.
Replace any class names starting with `Notificare` (for example, `NotificarePush`, `NotificareGeo`, `NotificareDevice`, etc.) with their Actito equivalents (`ActitoPush`, `ActitoGeo`, `ActitoDevice`, and so on).

Similarly, update all imports starting with `import Notificare` (for example, `import NotificarePushKit`, `import NotificareGeoKit`, etc.) with their Actito equivalents (`import ActitoPushKit`, `import ActitoGeoKit`, and so on).

For example, here’s how implementing push delegate should be updated:

```diff
- import NotificareKit
- import NotificarePushKit
+ import ActitoKit
+ import ActitoPushKit

- internal class AppDelegate: NSObject, UIApplicationDelegate, NotificarePushDelegate {
+ internal class AppDelegate: NSObject, UIApplicationDelegate, ActitoPushDelegate {
    internal func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // ...

-        Notificare.shared.push().delegate = self
+        Actito.shared.push().delegate = self
    }
    
-    internal func notificare(_ notificarePush: NotificarePush, didOpenNotification notification: NotificareNotification) {
+    internal func actito(_ actitoPush: ActitoPush, didOpenNotification notification: ActitoNotification) {
        // ...
     }
}
```

> **Tip:**
>
> A global search-and-replace can accelerate this migration, but review your code carefully — especially where custom extensions or wrappers reference old `Notificare` types or import names.

#### Overriding Localizable Resources

If your project overrides SDK-provided localizable strings or other resources, you must update their names to align with the new Actito namespace.
All resource identifiers previously prefixed with `notificare_` should now use the `actito_` prefix instead.

For example, in your `fr.lproj/Localizable.strings` file:

```diff
- notificare_cancel_button = "Annuler";
+ actito_cancel_button = "Annuler";
```

> **Tip:**
>
> A global search for `notificare_` in your localizable folder will help you quickly locate and rename all relevant keys to the new `actito_` format.


#### Refreshing the inbox becomes a suspending function

The `refresh()` method from the `ActitoInboxKit` module has been converted into an **asynchronous function**. This change ensures that the entire refresh process completes asynchronously, providing better control over execution flow and error handling.

Example migration:

```diff
- Actito.shared.inbox().refresh()

+ do {
+     try await Actito.shared.inbox().refresh()
+ } catch {
+     // Handle error
+ }
```

#### Restricted Tag Naming

Tag naming rules have been tightened to ensure consistency.
Tags added using `Actito.shared.device().addTag()` or `Actito.shared.device().addTags()` must now adhere to the following constraints:

- The tag name must be between 3 and 64 characters in length.
- Tags must start and end with an alphanumeric character.
- Only letters, digits, underscores (`_`), and hyphens (`-`) are allowed within the name.

> **Example:**
>
> ✅ `premium_user`  ✅ `en-GB`  ❌ @user


#### Restricted Event Naming and Payload Size

Event naming and payload validation rules have also been standardized.
Custom events logged with `Actito.shared.events().logCustom()` must comply with the following:

- Event names must be between 3 and 64 characters.
- Event names must start and end with an alphanumeric character.
- Only letters, digits, underscores (`_`), and hyphens (`-`) are permitted.
- The event data payload is limited to 2 KB in size. Ensure you are not sending excessively large or deeply nested objects when calling: `Actito.shared.events().logCustom(eventName, data: data)`.

> **Tip:**
>
> To avoid exceeding the payload limit, keep your event data minimal — include only the essential key–value pairs required for personalized content or campaign targeting.

## Other changes

- Removed `NotificareEvent` from public models. It was only intended for **internal** use and should not affect you.
- Removed `NotificareRegionSession` from public models. It was only intended for **internal** use and should not affect you.
