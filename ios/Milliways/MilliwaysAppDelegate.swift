//
//  MilliwaysAppDelegate.swift
//  Milliways
//
//  Forwards Mobilewright `device.openUrl` TrueCoverage URLs into TestChimpRum. SwiftUI `.onOpenURL`
//  alone can miss URLs delivered via UIApplication when the app is already foreground.
//

import OSLog
import TestChimpRum
import UIKit

private enum MilliwaysTrueCoverageLog {
    private static let logger = Logger(subsystem: "com.mobilenext.Milliways", category: "MilliwaysTC")

    static func isTrueCoverageAutomation(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "testchimp-rum" && url.host?.lowercased() == "truecoverage"
    }

    static func logOpenURLIncoming(_ url: URL, source: String) {
        #if DEBUG
        let scheme = url.scheme ?? "nil"
        let host = url.host ?? "nil"
        let path = url.path
        let absPrefix = String(url.absoluteString.prefix(160))
        logger.debug(
            "openURL incoming source=\(source, privacy: .public) scheme=\(scheme, privacy: .public) host=\(host, privacy: .public) path=\(path, privacy: .public) absPrefix=\(absPrefix, privacy: .public)"
        )
        #endif
    }

    static func log(url: URL, handled: Bool, source: String) {
        #if DEBUG
        guard isTrueCoverageAutomation(url) else { return }
        let path = url.path.lowercased()
        MilliwaysRumDiagnostics.recordTrueCoverageHandle(path: path, handled: handled)
        switch path {
        case "/v1/clear":
            logger.info(
                "TrueCoverage: CI context CLEAR handled=\(handled, privacy: .public) source=\(source, privacy: .public) (emits omit ci until SET)"
            )
        case "/v1/set":
            let pLen = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "p" })?.value?.count ?? 0
            logger.info(
                "TrueCoverage: CI context SET handled=\(handled, privacy: .public) p_len=\(pLen, privacy: .public) source=\(source, privacy: .public) (if false, ingested events will lack ci_test_info)"
            )
        case "/v1/flush":
            logger.info(
                "TrueCoverage: RUM buffer FLUSH handled=\(handled, privacy: .public) source=\(source, privacy: .public)"
            )
        default:
            logger.info(
                "TrueCoverage: automation path=\(path, privacy: .public) handled=\(handled, privacy: .public) source=\(source, privacy: .public)"
            )
        }
        #endif
    }

    static func logNonTrueCoverageSdkResult(handled: Bool, source: String) {
        #if DEBUG
        logger.debug(
            "openURL non-TrueCoverage handledBySDK=\(handled, privacy: .public) source=\(source, privacy: .public)"
        )
        #endif
    }
}

enum MilliwaysTrueCoverageOpenURL {
    /// Single entry for automation URLs: forwards to the SDK and logs (DEBUG) for Simulator troubleshooting.
    @discardableResult
    static func handle(_ url: URL, source: String) -> Bool {
        #if DEBUG
        MilliwaysTrueCoverageLog.logOpenURLIncoming(url, source: source)
        if !MilliwaysTrueCoverageLog.isTrueCoverageAutomation(url) {
            MilliwaysRumDiagnostics.recordNonTrueCoverageOpen(
                scheme: url.scheme,
                host: url.host,
                path: url.path
            )
        }
        #endif
        let handled = TestChimpRum.handleAutomationURL(url)
        #if DEBUG
        if MilliwaysTrueCoverageLog.isTrueCoverageAutomation(url) {
            MilliwaysTrueCoverageLog.log(url: url, handled: handled, source: source)
        } else {
            MilliwaysTrueCoverageLog.logNonTrueCoverageSdkResult(handled: handled, source: source)
        }
        #endif
        return handled
    }
}

final class MilliwaysAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        MilliwaysTrueCoverageOpenURL.handle(url, source: "AppDelegate")
    }
}
