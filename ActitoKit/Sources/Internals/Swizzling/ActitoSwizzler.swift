//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

// private typealias ApplicationDidBecomeActive = @convention(c) (Any, Selector, UIApplication) -> Void
// private typealias ApplicationWillResignActive = @convention(c) (Any, Selector, UIApplication) -> Void
private typealias ApplicationDidRegisterForRemoteNotificationsWithDeviceToken = @convention(c) (Any, Selector, UIApplication, Data) -> Void
private typealias ApplicationDidFailToRegisterForRemoteNotificationsWithError = @convention(c) (Any, Selector, UIApplication, Error) -> Void
private typealias ApplicationDidReceiveRemoteNotification = @convention(c) (Any, Selector, UIApplication, [AnyHashable: Any], @escaping (UIBackgroundFetchResult) -> Void) -> Void
private typealias ApplicationOpenURL = @convention(c) (Any, Selector, UIApplication, URL, [UIApplication.OpenURLOptionsKey: Any]) -> Bool
private typealias ApplicationContinueUserActivity = @convention(c) (Any, Selector, UIApplication, NSUserActivity, ([UIUserActivityRestoring]?) -> Void) -> Bool

private enum AssociatedObjectKeys {
    static var originalClass = "Actito_OriginalClass"
    static var originalImplementations = "Actito_OriginalImplementations"
    static var interceptors = "Actito_Interceptors"
}

private var gOriginalAppDelegate: UIApplicationDelegate?
private var gAppDelegateSubClass: AnyClass?

public class ActitoSwizzler: NSProxy {
    private static var interceptors: [String: ActitoAppDelegateInterceptor] = [:]

    /// Using Swift's lazy evaluation of a static property we get the same
    /// thread-safety and called-once guarantees as dispatch_once provided.
    private static let runOnce: () = {
        weak var appDelegate = UIApplication.shared.delegate
        proxyAppDelegate(appDelegate)
    }()

    private static let runOnceRemoteNotifications: () = {
        createAPNSMethodImplementations()
    }()

    public static func setup(withRemoteNotifications: Bool = false) {
        // Let the property be initialized and run its block.
        _ = runOnce

        if withRemoteNotifications {
            _ = runOnceRemoteNotifications
        }
    }

    public static func addInterceptor(_ interceptor: ActitoAppDelegateInterceptor) -> String? {
        let id = String(describing: type(of: interceptor))

        if ActitoSwizzler.interceptors[id] != nil {
            logger.debug("Interceptor '\(id)' is already registered. Replacing...")
        }

        // Save the interceptor.
        ActitoSwizzler.interceptors[id] = interceptor

        logger.debug("Interceptor saved with ID: '\(id)'")

        return id
    }

    public static func removeInterceptor(_ interceptor: ActitoAppDelegateInterceptor) {
        let id = String(describing: type(of: interceptor))

        if ActitoSwizzler.interceptors[id] == nil {
            logger.debug("Interceptor '\(id)' not registered. Skipping removal...")
            return
        }

        // Remove the interceptor.
        ActitoSwizzler.interceptors.removeValue(forKey: id)
    }

    private static func proxyAppDelegate(_ appDelegate: UIApplicationDelegate?) {
        guard let appDelegate = appDelegate else {
            logger.warning(
                "Could not create the App Delegate Proxy. The original App Delegate instance is nil."
            )
            return
        }

        gAppDelegateSubClass = createSubClass(from: appDelegate)
        reassignAppDelegate()
    }

    private static func reassignAppDelegate() {
        weak var delegate = UIApplication.shared.delegate
        UIApplication.shared.delegate = nil
        UIApplication.shared.delegate = delegate
        gOriginalAppDelegate = delegate
        // TODO: observe UIApplication
    }

    /// Creates a new subclass of the class of the given object and sets the isa value of the given object to the new subclass.
    /// Additionally this copies methods to that new subclass that allow us to intercept UIApplicationDelegate methods.
    /// This is better known as isa swizzling.
    ///
    /// - Parameter originalDelegate: The object to which you want to isa swizzle.
    /// - Returns: The new subclass.
    private static func createSubClass(from originalDelegate: UIApplicationDelegate) -> AnyClass? {
        let originalClass = type(of: originalDelegate)
        let newClassName = "\(originalClass)_\(UUID().uuidString)"

        guard NSClassFromString(newClassName) == nil else {
            logger.warning("Could not create the App Delegate Proxy. The subclass already exists.")
            return nil
        }

        // Register the new class as subclass of the real one. Do not allocate more than the real class size.
        guard let subClass = objc_allocateClassPair(originalClass, newClassName, 0) else {
            logger.warning("Could not create the App Delegate Proxy. The subclass already exists.")
            return nil
        }

        // Add ActitoSwizzler's UIApplicationDelegate methods to the subclass and store the real implementations
        // so the invocations can be forwarded to the real ones.
        createMethodImplementations(in: subClass, withOriginalDelegate: originalDelegate)

        // Override the description too so the custom class name will not show up.
        overrideDescription(in: subClass)

        // Store the original class in a fake property of the original delegate.
        objc_setAssociatedObject(
            originalDelegate,
            &AssociatedObjectKeys.originalClass,
            originalClass,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        // The subclass size has to be exactly the same size with the original class size. The subclass
        // cannot have more ivars/properties than its superclass since it will cause an offset in memory
        // that can lead to overwriting the isa of an object in the next frame.
        guard class_getInstanceSize(originalClass) == class_getInstanceSize(subClass) else {
            logger.warning("""
            Could not create the App Delegate Proxy. \
            The original class' and subclass' sizes do not match.
            """)
            return nil
        }

        // Make the newly created class to be the subclass of the real App Delegate class.
        objc_registerClassPair(subClass)
        if object_setClass(originalDelegate, subClass) != nil {
            logger.info("""
            Successfully created the App Delegate Proxy. \
            To disable automatic proxy, set the flag 'SWIZZLING_ENABLED' to NO on the NotificareOptions.plist.
            """)
        }

        return subClass
    }

    private static func createMethodImplementations(
        in subClass: AnyClass,
        withOriginalDelegate originalDelegate: UIApplicationDelegate
    ) {
        let originalClass = type(of: originalDelegate)
        var originalImplementationsStore: [String: NSValue] = [:]

        //        // For applicationDidBecomeActive:
        //        proxyInstanceMethod(
        //            toClass: subClass,
        //            withSelector: #selector(applicationDidBecomeActive(_:)),
        //            fromClass: ActitoSwizzler.self,
        //            fromSelector: #selector(applicationDidBecomeActive(_:)),
        //            withOriginalClass: originalClass,
        //            storeOriginalImplementationInto: &originalImplementationsStore
        //        )
        //
        //        // For applicationWillResignActive:
        //        proxyInstanceMethod(
        //            toClass: subClass,
        //            withSelector: #selector(applicationWillResignActive(_:)),
        //            fromClass: ActitoSwizzler.self,
        //            fromSelector: #selector(applicationWillResignActive(_:)),
        //            withOriginalClass: originalClass,
        //            storeOriginalImplementationInto: &originalImplementationsStore
        //        )

        // For application(_:open:options:)
        proxyInstanceMethod(
            toClass: subClass,
            withSelector: NSSelectorFromString("application:openURL:options:"),
            fromClass: ActitoSwizzler.self,
            fromSelector: #selector(application(_:open:options:)),
            withOriginalClass: originalClass,
            storeOriginalImplementationInto: &originalImplementationsStore
        )

        // For #selector(application(_:continue:restorationHandler:))
        proxyInstanceMethod(
            toClass: subClass,
            withSelector: NSSelectorFromString("application:continueUserActivity:restorationHandler:"),
            fromClass: ActitoSwizzler.self,
            fromSelector: #selector(application(_:continue:restorationHandler:)),
            withOriginalClass: originalClass,
            storeOriginalImplementationInto: &originalImplementationsStore
        )

        // Store original implementations
        objc_setAssociatedObject(
            originalDelegate,
            &AssociatedObjectKeys.originalImplementations,
            originalImplementationsStore,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    private static func createAPNSMethodImplementations() {
        guard let originalDelegate = gOriginalAppDelegate else {
            logger.error("Could not proxy APNS methods. The orignal App Delegate was nil.")
            return
        }

        guard let subClass = gAppDelegateSubClass else {
            logger.error("Could not proxy APNS methods. The subclass was nil.")
            return
        }

        guard var originalImplementationsStore = objc_getAssociatedObject(
            originalDelegate,
            &AssociatedObjectKeys.originalImplementations
        ) as? [String: NSValue] else {
            logger.error("Could not proxy APNS methods. The original implementations store was nil.")
            return
        }

        // For application:didRegisterForRemoteNotificationsWithDeviceToken:
        proxyInstanceMethod(
            toClass: subClass,
            withSelector: #selector(application(_:didRegisterForRemoteNotificationsWithDeviceToken:)),
            fromClass: ActitoSwizzler.self,
            fromSelector: #selector(application(_:didRegisterForRemoteNotificationsWithDeviceToken:)),
            withOriginalClass: type(of: originalDelegate),
            storeOriginalImplementationInto: &originalImplementationsStore
        )

        // For application:didFailToRegisterForRemoteNotificationsWithError:
        proxyInstanceMethod(
            toClass: subClass,
            withSelector: #selector(application(_:didFailToRegisterForRemoteNotificationsWithError:)),
            fromClass: ActitoSwizzler.self,
            fromSelector: #selector(application(_:didFailToRegisterForRemoteNotificationsWithError:)),
            withOriginalClass: type(of: originalDelegate),
            storeOriginalImplementationInto: &originalImplementationsStore
        )

        // For application:didReceiveRemoteNotification:fetchCompletionHandler:
        proxyInstanceMethod(
            toClass: subClass,
            withSelector: #selector(application(_:didReceiveRemoteNotification:fetchCompletionHandler:)),
            fromClass: ActitoSwizzler.self,
            fromSelector: #selector(application(_:didReceiveRemoteNotification:fetchCompletionHandler:)),
            withOriginalClass: type(of: originalDelegate),
            storeOriginalImplementationInto: &originalImplementationsStore
        )
    }

    private static func overrideDescription(in subClass: AnyClass) {
        // Override the description so the custom class name will not show up.
        addInstanceMethod(
            toClass: subClass,
            toSelector: #selector(description),
            fromClass: ActitoSwizzler.self,
            fromSelector: #selector(originalDescription)
        )
    }

    // swiftlint:disable:next function_parameter_count
    private static func proxyInstanceMethod(
        toClass destinationClass: AnyClass,
        withSelector destinationSelector: Selector,
        fromClass sourceClass: AnyClass,
        fromSelector sourceSelector: Selector,
        withOriginalClass originalClass: AnyClass,
        storeOriginalImplementationInto originalImplementationsStore: inout [String: NSValue]
    ) {
        addInstanceMethod(
            toClass: destinationClass,
            toSelector: destinationSelector,
            fromClass: sourceClass,
            fromSelector: sourceSelector
        )

        let sourceImplementation = methodImplementation(for: destinationSelector, from: originalClass)
        let sourceImplementationPointer = NSValue(pointer: UnsafePointer(sourceImplementation))

        let destinationSelectorStr = NSStringFromSelector(destinationSelector)
        originalImplementationsStore[destinationSelectorStr] = sourceImplementationPointer
    }

    private static func addInstanceMethod(
        toClass destinationClass: AnyClass,
        toSelector destinationSelector: Selector,
        fromClass sourceClass: AnyClass,
        fromSelector sourceSelector: Selector
    ) {
        let method = class_getInstanceMethod(sourceClass, sourceSelector)!
        let methodImplementation = method_getImplementation(method)
        let methodTypeEncoding = method_getTypeEncoding(method)

        if !class_addMethod(destinationClass, destinationSelector, methodImplementation, methodTypeEncoding) {
            logger.warning("""
            Could not add instance method with selector '\(destinationSelector)' as it already exists in the \
            destination class.
            """)
        }
    }

    private static func methodImplementation(for selector: Selector, from fromClass: AnyClass) -> IMP? {
        guard let method = class_getInstanceMethod(fromClass, selector) else {
            return nil
        }

        return method_getImplementation(method)
    }

    private static func originalMethodImplementation<T>(for selector: Selector, object: Any) -> T? {
        let originalImplementationsStore = objc_getAssociatedObject(
            object,
            &AssociatedObjectKeys.originalImplementations
        ) as? [String: NSValue]

        guard let pointer = originalImplementationsStore?[NSStringFromSelector(selector)],
              let pointerValue = pointer.pointerValue
        else {
            return nil
        }

        return unsafeBitCast(pointerValue, to: T.self)
    }

    @objc private func originalDescription() -> String {
        guard
            let originalClass = objc_getAssociatedObject(self, &AssociatedObjectKeys.originalClass) as? AnyClass
        else {
            return ""
        }

        let originalClassName = NSStringFromClass(originalClass)
        let pointerHex = String(format: "%p", unsafeBitCast(self, to: Int.self))

        return "<\(originalClassName): \(pointerHex)>"
    }
}

extension ActitoSwizzler {
    //    @objc private func applicationDidBecomeActive(_ application: UIApplication) {
    //        ActitoSwizzler.interceptors.forEach { _, interceptor in
    //            interceptor.applicationDidBecomeActive?(application)
    //        }
    //
    //        let selector = #selector(applicationDidBecomeActive)
    //        let originalImplementation: ApplicationDidBecomeActive? = ActitoSwizzler.originalMethodImplementation(
    //            for: selector,
    //            object: self
    //        )
    //
    //        originalImplementation?(self, selector, application)
    //    }
    //
    //    @objc private func applicationWillResignActive(_ application: UIApplication) {
    //        ActitoSwizzler.interceptors.forEach { _, interceptor in
    //            interceptor.applicationWillResignActive?(application)
    //        }
    //
    //        let selector = #selector(applicationWillResignActive)
    //        let originalImplementation: ApplicationWillResignActive? = ActitoSwizzler.originalMethodImplementation(
    //            for: selector,
    //            object: self
    //        )
    //
    //        originalImplementation?(self, selector, application)
    //    }

    @MainActor
    @objc private func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ActitoSwizzler.interceptors.forEach { _, interceptor in
            interceptor.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }

        let selector = #selector(application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        let originalImplementation: ApplicationDidRegisterForRemoteNotificationsWithDeviceToken? =
        ActitoSwizzler.originalMethodImplementation(for: selector, object: self)

        originalImplementation?(self, selector, application, deviceToken)
    }

    @MainActor
    @objc private func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ActitoSwizzler.interceptors.forEach { _, interceptor in
            interceptor.application?(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }

        let selector = #selector(application(_:didFailToRegisterForRemoteNotificationsWithError:))
        let originalImplementation: ApplicationDidFailToRegisterForRemoteNotificationsWithError? =
        ActitoSwizzler.originalMethodImplementation(for: selector, object: self)

        originalImplementation?(self, selector, application, error)
    }

    @MainActor
    @objc private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ActitoSwizzler.interceptors.forEach { _, interceptor in
            interceptor.application?(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        }

        let selector = #selector(application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
        let originalImplementation: ApplicationDidReceiveRemoteNotification? =
        ActitoSwizzler.originalMethodImplementation(for: selector, object: self)

        originalImplementation?(self, selector, application, userInfo, completionHandler)
    }

    @MainActor
    @objc private func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        var interceptorsResult = false

        ActitoSwizzler.interceptors.forEach { _, interceptor in
            let result = interceptor.application?(application, open: url, options: options) ?? false
            interceptorsResult = interceptorsResult || result
        }

        let selector = NSSelectorFromString("application:openURL:options:")
        let originalImplementation: ApplicationOpenURL? =
        ActitoSwizzler.originalMethodImplementation(for: selector, object: self)

        let originalResult = originalImplementation?(self, selector, application, url, options) ?? false

        return interceptorsResult || originalResult
    }

    @MainActor
    @objc private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        var interceptorsResult = false

        ActitoSwizzler.interceptors.forEach { _, interceptor in
            let result = interceptor.application?(application, continue: userActivity, restorationHandler: restorationHandler) ?? false
            interceptorsResult = interceptorsResult || result
        }

        let selector = NSSelectorFromString("application:continueUserActivity:restorationHandler:")
        let originalImplementation: ApplicationContinueUserActivity? =
        ActitoSwizzler.originalMethodImplementation(for: selector, object: self)

        let originalResult = originalImplementation?(self, selector, application, userActivity, restorationHandler) ?? false

        return interceptorsResult || originalResult
    }
}
