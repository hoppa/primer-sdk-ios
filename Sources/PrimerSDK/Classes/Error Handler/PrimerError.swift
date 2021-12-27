//
//  Error.swift
//  PrimerSDK
//
//  Created by Evangelos Pittas on 16/3/21.
//

#if canImport(UIKit)

// swiftlint:disable file_length
import Foundation
import UIKit

internal protocol PrimerErrorProtocol: CustomNSError, LocalizedError {
    var errorId: String { get }
    var exposedError: Error { get }
    var extraUserInfo: [String: String]? { get }
}

internal enum PrimerInternalError: PrimerErrorProtocol {
    case generic(message: String, userInfo: [String: String]?)
    case invalidClientToken(userInfo: [String: String]?)
    case missingPrimerConfiguration(userInfo: [String: String]?)
    case missingPrimerDelegate(userInfo: [String: String]?)
    case underlyingErrors(errors: [Error], userInfo: [String: String]?)
    
    var errorId: String {
        switch self {
        case .generic:
            return "primer-generic"
        case .invalidClientToken:
            return "invalid-client-token"
        case .missingPrimerConfiguration:
            return "missing-configuration"
        case .missingPrimerDelegate:
            return "missing-primer-delegate"
        case .underlyingErrors:
            return "generic-underlying-errors"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .generic(let message, let userInfo):
            if let userInfo = userInfo,
                let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: .fragmentsAllowed),
               let jsonStr = jsonData.prettyPrintedJSONString as String? {
                return "[\(errorId)] Generic error | Message: \(message) | Data: \(jsonStr))"
            } else {
                return "[\(errorId)] Generic error | Message: \(message)"
            }
            
        case .invalidClientToken:
            return "Client token is not valid"
            
        case .missingPrimerConfiguration:
            return "[\(errorId)] Missing SDK configuration"
            
        case .missingPrimerDelegate:
            return "[\(errorId)] Primer delegate has not been set"
            
        case .underlyingErrors(let errors, _):
            return "[\(errorId)] Multiple errors occured: \(errors.combinedDescription)"
        }
    }
    
    var extraUserInfo: [String: String]? {
        var tmpUserInfo: [String: String] = ["createdAt": Date().toString()]
        
        switch self {
        case .generic(_, let userInfo):
            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
        case .invalidClientToken(let userInfo):
            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
        case .missingPrimerConfiguration(let userInfo):
            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
        case .missingPrimerDelegate(let userInfo):
            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
        case .underlyingErrors(_, let userInfo):
            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
        }
        
        return tmpUserInfo
    }
    
    var errorUserInfo: [String : Any] {
        return extraUserInfo ?? [:]
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .generic:
            return nil
        case .invalidClientToken:
            return "Check if the token you have provided is a valid token (not nil and not expired)."
        case .missingPrimerConfiguration:
            return "Check if you have an active internet connection."
        case .missingPrimerDelegate:
            return nil
        case .underlyingErrors:
            return "Check underlying errors for more information."
        }
    }
    
    var exposedError: Error {
        return self
    }
}

internal enum NetworkError: PrimerErrorProtocol {
    case connectivityErrors(errors: [Error], userInfo: [String: String]?)
    case invalidUrl(url: String?, userInfo: [String: String]?)
    case invalidValue(key: String, value: Any?, userInfo: [String: String]?)
    case noData(userInfo: [String: String]?)
    case serverError(status: Int, response: PrimerServerErrorResponse?, userInfo: [String: String]?)
    case unauthorized(url: String, method: HTTPMethod, userInfo: [String: String]?)
    case underlyingErrors(errors: [Error], userInfo: [String: String]?)
    
    var errorId: String {
        switch self {
        case .connectivityErrors:
            return "connectivity-errors"
        case .invalidUrl:
            return "invalid-url"
        case .invalidValue:
            return "invalid-value"
        case .noData:
            return "no-data"
        case .serverError:
            return "server-error"
        case .unauthorized:
            return "unauthorized"
        case .underlyingErrors:
            return "underlying-errors"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .connectivityErrors(let errors, _):
            return "[\(errorId)] Connectivity failure | Errors: \(errors.combinedDescription)"
        case .invalidUrl(let url, _):
            return "[\(errorId)] Invalid URL \(url ?? "nil")"
        case .invalidValue(let key, let value, _):
            return "[\(errorId)] Invalid value \(value ?? "nil") for key \(key)"
        case .noData:
            return "[\(errorId)] No data"
        case .serverError(let status, let response, _):
            var resStr: String = "nil"
            if let response = response,
               let resData = try? JSONEncoder().encode(response),
                let str = resData.prettyPrintedJSONString as String?
            {
                resStr = str
            }
            return "[\(errorId)] Server error [\(status)] Response: \(resStr)"
        case .unauthorized(let url, let method, _):
            return "[\(errorId)] Unauthorized response for URL \(url) [\(method.rawValue)]"
        case .underlyingErrors(let errors, _):
            return "[\(errorId)] Multiple errors occured | Errors \(errors.combinedDescription)"
        }
    }
    
    var extraUserInfo: [String: String]? {
        var tmpUserInfo: [String: String] = ["createdAt": Date().toString()]
        
//        switch self {
//        case .generic(_, let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .invalidClientToken(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .missingPrimerConfiguration(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .missingPrimerDelegate(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .underlyingErrors(_, let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        }
        
        return tmpUserInfo
    }
    
    var errorUserInfo: [String : Any] {
        return extraUserInfo ?? [:]
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .connectivityErrors:
            return "Check underlying conectivity errors for more information."
        case .invalidUrl:
            return "Provide a valid URL, meaning that it must include http(s):// at the begining and also follow URL formatting rules."
        case .invalidValue(let key, let value, _):
            return "Check if value \(value ?? "nil") is valid for key \(key)"
        case .noData:
            return "If you were expecting data on this response, check that your backend has sent the appropriate data."
        case .serverError:
            return "Check the server's response to debug this error further."
        case .unauthorized:
            return "Check that the you have provided the SDK with a client token."
        case .underlyingErrors(let errors, _):
            return "Check underlying errors' recovery suggestions for more information.\nRecovery Suggestions:\n\(errors.compactMap({ ($0 as NSError).localizedRecoverySuggestion }))"
        }
    }
    
    var exposedError: Error {
        return self
    }
}

internal enum ParserError: PrimerErrorProtocol {
    case failedToEncode(message: String?, userInfo: [String: String]?)
    case failedToDecode(message: String?, userInfo: [String: String]?)
    case failedToSerialize(message: String?, userInfo: [String: String]?)
    
    var errorId: String {
        switch self {
        case .failedToEncode:
            return "failed-to-encode"
        case .failedToDecode:
            return "failed-to-decode"
        case .failedToSerialize:
            return "failed-to-serialize"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .failedToEncode(let message, _):
            return "[\(errorId)] Failed to encode\(message == nil ? "" : " (\(message!)")"
        case .failedToDecode(let message, _):
            return "[\(errorId)] Failed to decode\(message == nil ? "" : " (\(message!)")"
        case .failedToSerialize(let message, _):
            return "[\(errorId)] Failed to serialize\(message == nil ? "" : " (\(message!)")"
        }
    }
    
    var extraUserInfo: [String: String]? {
        var tmpUserInfo: [String: String] = ["createdAt": Date().toString()]
        
//        switch self {
//        case .generic(_, let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .invalidClientToken(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .missingPrimerConfiguration(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .missingPrimerDelegate(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .underlyingErrors(_, let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        }
        
        return tmpUserInfo
    }
    
    var errorUserInfo: [String : Any] {
        return extraUserInfo ?? [:]
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .failedToEncode:
            return "Check object's encode(to:) function for wrong CodingKeys, or unexpected values."
        case .failedToDecode:
            return "Check object's init(from:) function for wrong CodingKeys, or unexpected values."
        case .failedToSerialize:
            return "Check if all object's properties can be serialized."
        }
    }

    var exposedError: Error {
        return self
    }
}

internal enum ValidationError: PrimerErrorProtocol {
    case invalidCardholderName(userInfo: [String: String]?)
    case invalidCardnumber(userInfo: [String: String]?)
    case invalidCvv(userInfo: [String: String]?)
    case invalidExpiryDate(userInfo: [String: String]?)
    
    var errorId: String {
        switch self {
        case .invalidCardholderName:
            return "invalid-cardholder-name"
        case .invalidCardnumber:
            return "invalid-cardnumber"
        case .invalidCvv:
            return "invalid-cvv"
        case .invalidExpiryDate:
            return "invalid-expiry-date"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidCardholderName:
            return "[\(errorId)] Invalid cardholder name"
        case .invalidCardnumber:
            return "[\(errorId)] Invalid cardnumber"
        case .invalidCvv:
            return "[\(errorId)] Invalid CVV"
        case .invalidExpiryDate:
            return "[\(errorId)] Invalid expiry date"
        }
    }
    
    var extraUserInfo: [String: String]? {
        var tmpUserInfo: [String: String] = ["createdAt": Date().toString()]
        
//        switch self {
//        case .generic(_, let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .invalidClientToken(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .missingPrimerConfiguration(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .missingPrimerDelegate(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .underlyingErrors(_, let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        }
        
        return tmpUserInfo
    }
    
    var errorUserInfo: [String : Any] {
        return extraUserInfo ?? [:]
    }
    
    var recoverySuggestion: String? {
        return nil
    }
    
    var exposedError: Error {
        return self
    }
}

internal enum PaymentError: PrimerErrorProtocol {
    case cancelled(paymentMethodType: PaymentMethodConfigType, userInfo: [String: String]?)
    case failedToCreateSession(error: Error?, userInfo: [String: String]?)
    case failedOnWebViewFlow(error: Error?, userInfo: [String: String]?)
    case failedToPerform3DS(error: Error?, userInfo: [String: String]?)
    case invalidUrl(url: String?, userInfo: [String: String]?)
    case invalid3DSKey(userInfo: [String: String]?)
    case invalidAmount(amount: Int?, userInfo: [String: String]?)
    case invalidCurrency(currency: String?, userInfo: [String: String]?)
    case invalidCountryCode(countryCode: String?, userInfo: [String: String]?)
    case invalidMerchantCapabilities(userInfo: [String: String]?)
    case invalidMerchantIdentifier(merchantIdentifier: String?, userInfo: [String: String]?)
    case invalidSupportedPaymentNetworks(userInfo: [String: String]?)
    case invalidValue(key: String, value: Any?, userInfo: [String: String]?)
    case unableToMakePaymentsOnProvidedNetworks(userInfo: [String: String]?)
    case unableToPresentPaymentMethod(paymentMethodType: PaymentMethodConfigType, userInfo: [String: String]?)
    case unsupportedIntent(intent: PrimerSessionIntent, userInfo: [String: String]?)
    
    var errorId: String {
        switch self {
        case .cancelled:
            return "payment-cancelled"
        case .failedToCreateSession:
            return "failed-to-create-session"
        case .failedOnWebViewFlow:
            return "failed-on-webview"
        case .failedToPerform3DS:
            return "failed-to-perform-3ds"
        case .invalid3DSKey:
            return "invalid-3ds-key"
        case .invalidUrl:
            return "invalid-url"
        case .invalidAmount:
            return "invalid-amount"
        case .invalidCurrency:
            return "invalid-currency"
        case .invalidCountryCode:
            return "invalid-country-code"
        case .invalidMerchantCapabilities:
            return "invalid-merchant-capabilities"
        case .invalidMerchantIdentifier:
            return "invalid-merchant-identifier"
        case .invalidSupportedPaymentNetworks:
            return "invalid-supported-payment-networks"
        case .invalidValue:
            return "invalid-value"
        case .unableToMakePaymentsOnProvidedNetworks:
            return "unable-to-make-payments-on-provided-networks"
        case .unableToPresentPaymentMethod:
            return "unable-to-present-payment-method"
        case .unsupportedIntent:
            return "unsupported-session-intent"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .cancelled(let paymentMethodType, _):
            return "[\(errorId)] Payment method \(paymentMethodType.rawValue) cancelled"
        case .failedToCreateSession(error: let error, _):
            return "[\(errorId)] Failed to create session with error: \(error?.localizedDescription ?? "nil")"
        case .failedOnWebViewFlow(error: let error, _):
            return "[\(errorId)] Failed on webview flow with error: \(error?.localizedDescription ?? "nil")"
        case .failedToPerform3DS(let error, _):
            return "[\(errorId)] Failed on perform 3DS with error: \(error?.localizedDescription ?? "nil")"
        case .invalid3DSKey:
            return "[\(errorId)] Invalid 3DS key"
        case .invalidUrl(url: let url, _):
            return "[\(errorId)] Invalid URL: \(url ?? "nil")"
        case .invalidAmount(amount: let amount, _):
            return "[\(errorId)] Invalid amount: \(amount == nil ? "nil" : "\(amount!)")"
        case .invalidCurrency(currency: let currency, _):
            return "[\(errorId)] Invalid currency: \(currency == nil ? "nil" : "\(currency!)")"
        case .invalidCountryCode(countryCode: let countryCode, _):
            return "[\(errorId)] Invalid country code: \(countryCode == nil ? "nil" : "\(countryCode!)")"
        case .invalidMerchantCapabilities:
            return "[\(errorId)] Invalid merchant capabilities"
        case .invalidMerchantIdentifier(merchantIdentifier: let merchantIdentifier, _):
            return "[\(errorId)] Invalid merchant identifier: \(merchantIdentifier == nil ? "nil" : "\(merchantIdentifier!)")"
        case .invalidSupportedPaymentNetworks:
            return "[\(errorId)] Invalid supported payment networks"
        case .invalidValue(key: let key, value: let value, _):
            return "[\(errorId)] Invalid value '\(value ?? "nil")' for key '\(key)'"
        case .unableToMakePaymentsOnProvidedNetworks:
            return "[\(errorId)] Unable to make payments on provided networks"
        case .unableToPresentPaymentMethod(let paymentMethodType, _):
            return "[\(errorId)] Unable to present payment method \(paymentMethodType.rawValue)"
        case .unsupportedIntent(let intent, _):
            return "[\(errorId)] Unsupported session intent \(intent.rawValue)"
        }
    }
    
    var extraUserInfo: [String: String]? {
        var tmpUserInfo: [String: String] = ["createdAt": Date().toString()]
        
//        switch self {
//        case .generic(_, let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .invalidClientToken(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .missingPrimerConfiguration(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .missingPrimerDelegate(let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        case .underlyingErrors(_, let userInfo):
//            tmpUserInfo = tmpUserInfo.merging(userInfo ?? [:]) { (_, new) in new }
//        }
        
        return tmpUserInfo
    }
    
    var errorUserInfo: [String : Any] {
        return extraUserInfo ?? [:]
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .cancelled:
            return nil
        case .failedToCreateSession:
            // We need to check all the possibilities of underlying errors, and provide a suggestion that makes sense
            return nil
        case .failedOnWebViewFlow:
            // We need to check all the possibilities of underlying errors, and provide a suggestion that makes sense
            return nil
        case .failedToPerform3DS(let error):
            // We need to check all the possibilities of underlying errors, and provide a suggestion that makes sense
            return nil
        case .invalidUrl(let url):
            // We need to check all the possibilities of underlying errors, and provide a suggestion that makes sense
            return nil
        case .invalid3DSKey:
            return "Contact Primer to enable 3DS on your account."
        case .invalidAmount:
            return "Check if you have provided a valid amount on your client session."
        case .invalidCurrency:
            return "Check if you have provided a valid currency code on your client session."
        case .invalidCountryCode:
            return "Check if you have provided a valid country code on your client session."
        case .invalidMerchantCapabilities:
            return nil
        case .invalidMerchantIdentifier:
            return "Check if you have provided a valid merchant identifier on the PrimerSettings."
        case .invalidSupportedPaymentNetworks:
            return nil
        case .invalidValue(let key, let value, _):
            return "Check if value \(value ?? "nil") is valid for key \(key)"
        case .unableToMakePaymentsOnProvidedNetworks:
            return nil
        case .unableToPresentPaymentMethod:
            return "Check if all necessary values have been provided on your client session. You can find the necessary values on our documentation (website)"
        case .unsupportedIntent(let intent, _):
            if intent == .checkout {
                return "Change the intent to .vault"
            } else {
                return "Change the intent to .checkout"
            }
        }
    }
    
    var exposedError: Error {
        return self
    }
}

fileprivate extension Array where Element == Error {
    var combinedDescription: String {
        var message: String = ""
        
        self.forEach { err in
            if let primerError = err as? PrimerErrorProtocol {
                message += "\(primerError.localizedDescription) | "
            } else {
                let nsErr = err as NSError
                message += "Domain: \(nsErr.domain), Code: \(nsErr.code), Description: \(nsErr.localizedDescription)  | "
            }
        }
        
        if message.hasSuffix(" | ") {
            message = String(message.dropLast(3))
        }
        
        return "[\(message)]"
    }
}

internal struct PrimerServerErrorResponse: Codable {
    var errorId: String
    var `description`: String
    var diagnosticsId: String
    var validationErrors: [String]?
}

#endif
