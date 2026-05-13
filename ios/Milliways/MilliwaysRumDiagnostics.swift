//
//  MilliwaysRumDiagnostics.swift
//  Milliways
//
//  Lightweight in-app state for correlating RUM emits with TrueCoverage openUrl handling (Simulator / Xcode Console).
//

import Foundation

enum MilliwaysRumDiagnostics {
    private static let lock = NSLock()
    private static var lastAutomationLabel: String = "none"
    private static var emitCallCount: Int = 0
    private static var lastEmitTitle: String = ""

    /// Updated after each `TestChimpRum.handleAutomationURL` for `testchimp-rum` TrueCoverage paths.
    static func recordTrueCoverageHandle(path: String?, handled: Bool) {
        let p = path?.lowercased() ?? ""
        lock.lock()
        defer { lock.unlock() }
        switch p {
        case "/v1/set":
            lastAutomationLabel = handled ? "set_ok" : "set_fail"
        case "/v1/clear":
            lastAutomationLabel = handled ? "clear_ok" : "clear_fail"
        case "/v1/flush":
            lastAutomationLabel = handled ? "flush_ok" : "flush_fail"
        default:
            if p.hasPrefix("/") {
                lastAutomationLabel = handled ? "automation_other_ok" : "automation_other_fail"
            }
        }
    }

    /// Any non-TrueCoverage URL the app was asked to open (Mobilewright, deep links, etc.).
    static func recordNonTrueCoverageOpen(scheme: String?, host: String?, path: String) {
        lock.lock()
        defer { lock.unlock() }
        let s = scheme ?? "nil"
        let h = host ?? "nil"
        lastAutomationLabel = "openurl_other scheme=\(s) host=\(h) path=\(path)"
    }

    static func recordEmit(title: String) {
        lock.lock()
        defer { lock.unlock() }
        emitCallCount += 1
        lastEmitTitle = title
    }

    static func snapshotForLog() -> (automation: String, emitCount: Int, lastTitle: String) {
        lock.lock()
        defer { lock.unlock() }
        return (lastAutomationLabel, emitCallCount, lastEmitTitle)
    }
}
