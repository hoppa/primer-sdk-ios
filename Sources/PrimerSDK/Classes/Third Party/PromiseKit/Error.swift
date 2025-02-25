import Foundation

internal enum PMKError: Error {
    /**
     The completionHandler with form `(T?, Error?)` was called with `(nil, nil)`.
     This is invalid as per Cocoa/Apple calling conventions.
     */
    case invalidCallingConvention

    /**
     A handler returned its own promise. 99% of the time, this is likely a 
     programming error. It is also invalid per Promises/A+.
     */
    case returnedSelf

    /** `when()`, `race()` etc. were called with invalid parameters, eg. an empty array. */
    case badInput

    /// The operation was cancelled
    case cancelled
    
    /// The operation timed out and was cancelled
    case timedOut
    
    /// `nil` was returned from `flatMap`
    @available(*, deprecated, message: "See: `compactMap`")
    case flatMap(Any, Any.Type)

    /// `nil` was returned from `compactMap`
    case compactMap(Any, Any.Type)

    /**
     The lastValue or firstValue of a sequence was requested but the sequence was empty.

     Also used if all values of this collection failed the test passed to `firstValue(where:)`.
     */
    case emptySequence

    /// no winner in `race(fulfilled:)`
    case noWinner
}

extension PMKError: CustomDebugStringConvertible {
    internal var debugDescription: String {
        switch self {
        case .flatMap(let obj, let type):
            return "Could not `flatMap<\(type)>`: \(obj)"
        case .compactMap(let obj, let type):
            return "Could not `compactMap<\(type)>`: \(obj)"
        case .invalidCallingConvention:
            return "A closure was called with an invalid calling convention, probably (nil, nil)"
        case .returnedSelf:
            return "A promise handler returned itself"
        case .badInput:
            return "Bad input was provided to a PromiseKit function"
        case .cancelled:
            return "The asynchronous sequence was cancelled"
        case .timedOut:
            return "The asynchronous sequence timed out"
        case .emptySequence:
            return "The first or last element was requested for an empty sequence"
        case .noWinner:
            return "All thenables passed to race(fulfilled:) were rejected"
        }
    }
}

extension PMKError: LocalizedError {
    internal var errorDescription: String? {
        return debugDescription
    }
}


//////////////////////////////////////////////////////////// Cancellation

/// An error that may represent the cancelled condition
internal protocol CancellableError: Error {
    /// returns true if this Error represents a cancelled condition
    var isCancelled: Bool { get }
}

extension Error {
    internal var isCancelled: Bool {
        do {
            throw self
        } catch PMKError.cancelled {
            return true
        } catch PMKError.timedOut {
            return true
        } catch let error as CancellableError {
            return error.isCancelled
        } catch URLError.cancelled {
            return true
        } catch CocoaError.userCancelled {
            return true
        } catch let error as NSError {
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
                let domain = error.domain
                let code = error.code
                return ("SKErrorDomain", 2) == (domain, code)
            #else
                return false
            #endif
        } catch {
            return false
        }
    }
}

/// Used by `catch` and `recover`
internal enum CatchPolicy {
    /// Indicates that `catch` or `recover` handle all error types including cancellable-errors.
    case allErrors

    /// Indicates that `catch` or `recover` handle all error except cancellable-errors.
    case allErrorsExceptCancellation
}
