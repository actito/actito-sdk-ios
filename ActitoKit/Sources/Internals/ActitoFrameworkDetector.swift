//
// Copyright (c) 2026 Actito. All rights reserved.
//

import Foundation
import Darwin

private typealias RCTVersionFn = @convention(c) () -> NSDictionary

internal final class ActitoFrameworkDetector {
    internal func detect() -> FrameworkInfo? {
        if isFlutter() {
            return FrameworkInfo(name: "Flutter", version: nil)
        }

        if isExpo() {
            return FrameworkInfo(name: "Expo (React Native)", version: getReactNativeVersion())
        }

        if isReactNative() {
            return FrameworkInfo(name: "React Native", version: getReactNativeVersion())
        }

        if isCapacitor() {
            return FrameworkInfo(name: "Capacitor", version: nil)
        }

        if isCordova() {
            return FrameworkInfo(name: "Cordova", version: getCordovaVersion())
        }

        if isDotNETMAUI() {
            return FrameworkInfo(name: ".NET MAUI", version: nil)
        }

        return nil
    }

    private func isFlutter() -> Bool {
        NSClassFromString("FlutterEngine") != nil
    }

    private func isExpo() -> Bool {
        NSClassFromString("EXExpoAppDelegate") != nil
    }

    private func isReactNative() -> Bool {
        NSClassFromString("RCTBridge") != nil ||
        NSClassFromString("RCTRootView") != nil
    }

    private func isCapacitor() -> Bool {
        NSClassFromString("CAPPlugin") != nil ||
        NSClassFromString("CAPPluginCall") != nil
    }

    private func isCordova() -> Bool {
        NSClassFromString("CDVViewController") != nil
    }

    private func isDotNETMAUI() -> Bool {
        let paths = [
            Bundle.main.privateFrameworksPath,
            Bundle.main.bundlePath,
        ]

        for path in paths.compactMap({ $0 }) {
            if let contents = try? FileManager.default.contentsOfDirectory(atPath: path) {
                if contents.contains(where: {
                    $0.contains("Mono") ||
                    $0.contains("monosgen") ||
                    $0.contains("libmono")
                }) {
                    return true
                }
            }
        }

        return false
    }

    private func getReactNativeVersion() -> String? {
        guard let sym = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "RCTGetReactNativeVersion") else {
            return nil
        }

        let fn = unsafeBitCast(sym, to: RCTVersionFn.self)

        guard let version = fn() as? [String: Any],
              let major = version["major"],
              let minor = version["minor"],
              let patch = version["patch"]
        else {
            return nil
        }

        return "\(major).\(minor).\(patch)"
    }

    private func getCordovaVersion() -> String? {
        do {
            if let path = Bundle.main.path(forResource: "www/cordova", ofType: "js") {
                let cordovaJs = try String(contentsOfFile: path)

                let regex = try NSRegularExpression(pattern: "PLATFORM_VERSION_BUILD_LABEL\\s*=\\s*'([^']+)'")

                if let match = regex.firstMatch(in: cordovaJs, range: NSRange(cordovaJs.startIndex..., in: cordovaJs)),
                   let range = Range(match.range(at: 1), in: cordovaJs)
                {
                    let version = String(cordovaJs[range])
                    return "\(version)"
                }
            }
        } catch {}

        return nil
    }

    internal struct FrameworkInfo {
        internal let name: String
        internal let version: String?
    }
}
