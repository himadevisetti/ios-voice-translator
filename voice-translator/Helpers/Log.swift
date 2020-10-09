//
//  Log.swift
//  voice-translator
//
//  Created by Hima Devisetti on 10/9/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import Foundation
import os.log

/// `Loggable` can be used to customize what a conforming object is referred to as a Log's category.
///
/// This can be used if you don't want to use the conforming object's type as the category when calling `Log(self)` from within the object.
///
/// e.g., if class `Car` conforms to `Loggable` and defines `logCategory` as `Tesla`, `Log(self)` will set the category to `Tesla`.
@available(iOS 13, tvOS 10, macOS 10.12, *)
public protocol Loggable {
    var logCategory: String { get }
}

/// This a wrapper that's used to abstract out direct use of Apple's logging APIs, to allow logging to be performed in a more convenient manner.
@available(iOS 13, tvOS 10, macOS 10.12, *)
public struct Log {

    // MARK: - Properties

    /// This can be set to `false` to completely disable logging. Defaults to `true`.
    public static var isLoggingEnabled = true
    /// This subsystem will be used whenever no subsystem is passed to an initializer. Defaults to `Bundle.main.bundleIdentifier`.
    public static var defaultSubsystem: String? = Bundle.main.bundleIdentifier
    /// This subsystem will be used in logging when no subsystem is passed to an initializer and when `defaultSubystem` is nil.
    public static var fallbackSubsystem: String = ""

    /// The subsystem that is used in logging.
    public let subsystem: String
    /// The category that is used in logging.
    public let category: String

    // MARK: - Object Lifecycle

    public init(_ category: String, subsystem: String? = Self.defaultSubsystem) {
        self.category = category
        self.subsystem = subsystem ?? Self.fallbackSubsystem
    }

    public init(_ subject: Any, subsystem: String? = Self.defaultSubsystem) {
        self.init("\(type(of: subject))", subsystem: subsystem)
    }

    public init(_ loggable: Loggable, subsystem: String? = Self.defaultSubsystem) {
        self.init(loggable.logCategory, subsystem: subsystem)
    }

    // MARK: - Helper Functions

    private func createOSLog(category: String) -> OSLog {
        guard
            Self.isLoggingEnabled
        else {
            return .disabled
        }

        return OSLog(subsystem: subsystem, category: category)
    }

    // MARK: - Logging Functions

    @discardableResult
    private func performLog(
        _ message: String,
        type: OSLogType,
        includeCodeLocation: Bool,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> String {
        var finalMessage = message
        if includeCodeLocation {
            finalMessage += " - \(file).\(function):\(line)"
        }

        os_log("%{public}@", log: createOSLog(category: category), type: type, finalMessage)
        return finalMessage
    }

    /// Use this level to capture information during development to diagnose a particular issue, whilst actively debugging. These logs aren’t captured unless enabled by a configuration change.
    ///
    /// The system's default behavior is to discard debug messages; it only captures them when you enable debug logging using the tools or a custom configuration.
    ///
    /// - Warning: All logging is performed publicly and without redactions, so sensitive data should not be logged.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - includeCodeLocation: Whether or not the code location of this log should be appended to the message. If `true`, this will use the implicitly passed `file`, `function`, and `line` parameters.
    ///   - file: See `includeCodeLocation`
    ///   - function: See `includeCodeLocation`
    ///   - line: See `includeCodeLocation`
    /// - Returns: The message that was logged.
    @discardableResult
    public func debug(
        _ message: String,
        includeCodeLocation: Bool = false,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> String {
        performLog(
            message,
            type: .debug,
            includeCodeLocation: includeCodeLocation,
            file: file,
            function: function,
            line: line
        )
    }

    /// Use this level to capture information about things that might result in a failure.
    ///
    /// The system's default behavior is to store the default messages in memory buffers. When the memory buffers are full, the system compresses those buffers and moves them to the data store. They remain there until a storage quota is exceeded, at which point the system purges the oldest messages.
    ///
    /// - Warning: All logging is performed publicly and without redactions, so sensitive data should not be logged.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - includeCodeLocation: Whether or not the code location of this log should be appended to the message. If `true`, this will use the implicitly passed `file`, `function`, and `line` parameters.
    ///   - file: See `includeCodeLocation`
    ///   - function: See `includeCodeLocation`
    ///   - line: See `includeCodeLocation`
    /// - Returns: The message that was logged.
    @discardableResult
    public func `default`(
        _ message: String,
        includeCodeLocation: Bool = false,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> String {
        performLog(
            message,
            type: .default,
            includeCodeLocation: includeCodeLocation,
            file: file,
            function: function,
            line: line
        )
    }

    /// Use this level to capture information about process-level errors.
    ///
    /// The system always saves error messages in the data store. They remain there until a storage quota is exceeded, at which point the system purges the oldest messages.
    /// When you log an error message, the system saves other messages to the data store. If an activity object exists, the system captures information for the entire process chain related to that activity.
    ///
    /// - Warning: All logging is performed publicly and without redactions, so sensitive data should not be logged.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - includeCodeLocation: Whether or not the code location of this log should be appended to the message. If `true`, this will use the implicitly passed `file`, `function`, and `line` parameters.
    ///   - file: See `includeCodeLocation`
    ///   - function: See `includeCodeLocation`
    ///   - line: See `includeCodeLocation`
    /// - Returns: The message that was logged.
    @discardableResult
    public func error(
        _ message: String,
        includeCodeLocation: Bool = false,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> String {
        performLog(
            message,
            type: .error,
            includeCodeLocation: includeCodeLocation,
            file: file,
            function: function,
            line: line
        )
    }

    /// Use this level only when you want to capture information about system-level or multi-process errors.
    ///
    /// The system always saves fault messages in the data store. They remain there until a storage quota is exceeded, at which point, the oldest messages are purged.
    /// When you log an fault message, the system saves other messages to the data store. If an activity object exists, the system captures information for the entire process chain related to that activity.
    ///
    /// - Warning: All logging is performed publicly and without redactions, so sensitive data should not be logged.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - includeCodeLocation: Whether or not the code location of this log should be appended to the message. If `true`, this will use the implicitly passed `file`, `function`, and `line` parameters.
    ///   - file: See `includeCodeLocation`
    ///   - function: See `includeCodeLocation`
    ///   - line: See `includeCodeLocation`
    /// - Returns: The message that was logged.
    @discardableResult
    public func fault(
        _ message: String,
        includeCodeLocation: Bool = false,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> String {
        performLog(
            message,
            type: .fault,
            includeCodeLocation: includeCodeLocation,
            file: file,
            function: function,
            line: line
        )
    }

    /// Use this level to capture information that may be helpful, but isn’t essential, for troubleshooting errors.
    ///
    /// The system's default behavior is to store info messages in memory buffers. The system purges these messages when the memory buffers are full.
    /// When a piece of code logs an error or fault message, the info messages are also copied to the data store. They remain there until a storage quota is exceeded, at which point the system purges the oldest messages.
    ///
    /// - Warning: All logging is performed publicly and without redactions, so sensitive data should not be logged.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - includeCodeLocation: Whether or not the code location of this log should be appended to the message. If `true`, this will use the implicitly passed `file`, `function`, and `line` parameters.
    ///   - file: See `includeCodeLocation`
    ///   - function: See `includeCodeLocation`
    ///   - line: See `includeCodeLocation`
    /// - Returns: The message that was logged.
    @discardableResult
    public func info(
        _ message: String,
        includeCodeLocation: Bool = false,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> String {
        performLog(
            message,
            type: .info,
            includeCodeLocation: includeCodeLocation,
            file: file,
            function: function,
            line: line
        )
    }

}
