//
//  PRTextField.swift
//  PrimerSDK
//
//  Created by Evangelos on 28/1/22.
//

#if canImport(UIKit)

import UIKit

public class PrimerCheckoutComponents {
    
    public static var delegate: PrimerCheckoutComponentsDelegate?
    
    public static func listAvailablePaymentMethodsTypes(forSession clientToken: String, completion: @escaping ([PaymentMethodConfigType]?, Error?) -> Void) {
        do {
            try ClientTokenService.storeClientToken(clientToken)
        } catch {
            completion(nil, error)
        }
        
        let primerConfigurationService: PaymentMethodConfigServiceProtocol = DependencyContainer.resolve()
        firstly {
            primerConfigurationService.fetchConfig()
        }
        .done {
            let availablePaymentMethodTypes = PrimerConfiguration.paymentMethodConfigs?.compactMap({ $0.type })
            completion(availablePaymentMethodTypes, nil)
        }
        .catch { err in
            completion(nil, err)
        }
    }
    
    public static func listInputElementTypes(for paymentMethodType: PaymentMethodConfigType) -> [PrimerInputElementType] {
        switch paymentMethodType {
        case .adyenAlipay:
            return []
        case .adyenDotPay:
            return []
        case .adyenGiropay:
            return []
        case .adyenIDeal:
            return []
        case .adyenMobilePay:
            return []
        case .adyenSofort:
            return []
        case .adyenTrustly:
            return []
        case .adyenTwint:
            return []
        case .adyenVipps:
            return []
        case .apaya:
            return []
        case .applePay:
            return []
        case .atome:
            return []
        case .buckarooBancontact:
            return []
        case .buckarooEps:
            return []
        case .buckarooGiropay:
            return []
        case .buckarooIdeal:
            return []
        case .buckarooSofort:
            return []
        case .goCardlessMandate:
            return []
        case .googlePay:
            return []
        case .hoolah:
            return []
        case .klarna:
            return []
        case .mollieBankcontact:
            return []
        case .mollieIdeal:
            return []
        case .payNLBancontact:
            return []
        case .payNLGiropay:
            return []
        case .payNLIdeal:
            return []
        case .payNLPayconiq:
            return []
        case .paymentCard:
            return [.cardNumber, .expiryDate, .cvv, .cardholderName]
        case .payPal:
            return []
        case .xfers:
            return []
        case .other(let rawValue):
            return []
        }
    }
    
    public static func makeButton(for paymentMethodType: PaymentMethodConfigType) -> UIButton? {
        switch paymentMethodType {
        case .applePay:
            guard let tokenizationViewModel = PrimerConfiguration.paymentMethodConfigs?.filter({ $0.type == .applePay }).first?.tokenizationViewModel else { return nil }
            return tokenizationViewModel.paymentMethodButton
            
        default:
            return nil
        }
    }
    
    public static func getAsset(for brand: PrimerAsset.Brand, assetType: PrimerAsset.ImageType) -> UIImage? {
        var imageName = brand.rawValue
        
        switch assetType {
        case .logo:
            imageName += "-logo"
        case .icon:
            imageName += "-icon"
        }
        
//        switch assetColor {
//        case .original:
//            break
//        case .light:
//            imageName += "-light"
//        case .dark:
//            imageName += "-dark"
//        }
        
        guard let image = UIImage(named: imageName, in: Bundle.primerResources, compatibleWith: nil) else { return nil }
        return image
    }
    
    public static func showCheckout(for paymentMethod: PaymentMethodConfigType) {
        PrimerCheckoutComponents.delegate?.onEvent(.configurationStarted)
        var settings: PrimerSettingsProtocol = DependencyContainer.resolve()
        settings.hasDisabledSuccessScreen = true
        settings.isInitialLoadingHidden = true
        Primer.shared.showPaymentMethod(paymentMethod, withIntent: .checkout, on: UIViewController())
    }
}



public struct PrimerAsset {
    public enum Brand: String, CaseIterable {
        case adyen, afterPay = "after-pay", aliPay = "ali-pay", alma, amazonPay = "amazon-pay", amex, apaya, applePay = "apple-pay", atome
        case bankcontact, banked, bizum, blik, bolt, boost, braintree, bridge, buckaroo
        case change, checkoutCom = "checkout", clearPay = "clear-pay", coinBase = "coinbase", coinPayments = "coinpayments"
        case dLocal = "d-local", directDebit = "direct-debit", discover, dotPay = "dotpay", eMerchantPay = "emerchantpay", eps, fintecture, fonoa, forter, fpx
        case gCash = "gcash", giroPay = "giropay", globalPayments = "global-payments", goCardless = "go-cardless", googlePay = "google-pay", grabPay = "grab-pay"
        case hoolah
        case iDeal = "ideal"
        case ingenico
        case jcb
        case klarna, kount
        case layBuy = "lay-buy", looker
        case masterCard = "master-card", mbWay = "mb-way", mercadoPago = "mercado-pago", metamask, mobilePay = "mobile-pay", mollie
        case neonomics, netSuite = "netsuite", nexi, nuvei
        case p24, payNL = "pay-nl", payconiq, payNow = "paynow", payPal = "paypal", primer, printful, ravelin, riskified
        case seon, sepa, sift, signifyd, sofort, stitch, stripe, swish
        case tableau, taxjar, telserv, tink, trilo, trueLayer = "truelayer", trueMoney = "truemoney", trustly, twillio, twint
        case vipps, visa, volt, voucherify, vyne
        case wordline, worldPay = "worldpay"
        case xfers
    }
    
    public enum ImageType {
        case logo, icon
    }
    
    public enum ImageColor {
        case original, light, dark
    }
}

extension PrimerCheckoutComponents {
    internal class Delegate: NSObject, UITextFieldDelegate {
        
        private var inputElement: PrimerInputElement
        private var inputElementDelegate: PrimerInputElementDelegate
        private var detectedType: Any?
        
        init(inputElement: PrimerInputElement, inputElementDelegate: PrimerInputElementDelegate) {
            self.inputElement = inputElement
            self.inputElementDelegate = inputElementDelegate
        }
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            guard let inputElementShouldFocus = self.inputElementDelegate.inputElementShouldFocus?(self.inputElement) else { return true }
            return inputElementShouldFocus
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.inputElementDelegate.inputElementDidFocus?(self.inputElement)
        }
        
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            guard let inputElementShouldBlur = self.inputElementDelegate.inputElementShouldBlur?(self.inputElement) else { return true }
            return inputElementShouldBlur
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            self.inputElementDelegate.inputElementDidBlur?(self.inputElement)
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let primerCheckoutComponentsTextField = textField as? PrimerCheckoutComponents.TextField else { return false }
            if !string.isEmpty {
                // Characters aren't in the allowed character set
                if let allowedCharacterSet = self.inputElement.type.allowedCharacterSet, string.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
                    return false
                }
            }
            
            let currentText = primerCheckoutComponentsTextField._text ?? ""
            
            var newText = (currentText as NSString).replacingCharacters(in: range, with: string) as String
            if let deformattedText = self.inputElement.type.clearFormatting(value: newText) as? String {
                newText = deformattedText
            }
            
            if let maxAllowedLength = self.inputElement.type.maxAllowedLength {
                if newText.count > maxAllowedLength {
                    return false
                }
            }
            
//            DispatchQueue.global(qos: .userInitiated).async {
//            DispatchQueue.main.async {
            
            if self.inputElement.type == .cardNumber {
                if let cardNetwork = self.inputElement.type.detectType(for: newText) as? CardNetwork {
                    if self.detectedType == nil, cardNetwork != .unknown {
                        self.detectedType = cardNetwork
                        self.inputElementDelegate.inputElementDidDetectType?(self.inputElement, type: self.detectedType)
                    } else if self.detectedType != nil, cardNetwork == .unknown {
                        self.detectedType = nil
                        self.inputElementDelegate.inputElementDidDetectType?(self.inputElement, type: self.detectedType)
                    }
                } else {
                    if self.detectedType != nil {
                        self.detectedType = nil
                        self.inputElementDelegate.inputElementDidDetectType?(self.inputElement, type: self.detectedType)
                    }
                }
            }
            
            if let cardNetwork = self.detectedType as? CardNetwork {
                if self.inputElement.type == .cardNumber,
                   let cardNetworkMaxAllowedLength = cardNetwork.validation?.lengths.max(),
                   newText.count > cardNetworkMaxAllowedLength {
                    return false
                }
                
            } else if let cardNetwork = primerCheckoutComponentsTextField.detectedValueType as? CardNetwork {
                if self.inputElement.type == .cvv {
                    if let cvvMaxAllowedLength = cardNetwork.validation?.code.length,
                       newText.count > cvvMaxAllowedLength {
                        return false
                    }
                }
            }
            
            let isValid = self.inputElement.type.validate(value: newText, detectedValueType: primerCheckoutComponentsTextField.detectedValueType)
            self.inputElementDelegate.inputElementValueIsValid?(self.inputElement, isValid: isValid)
            
            let formattedText = self.inputElement.type.format(value: newText)
            textField.text = formattedText as? String
            
            return false
        }
    }
}

#endif
