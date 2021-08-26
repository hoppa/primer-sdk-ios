//
//  Netcetera+Helpers.swift
//  PrimerSDK
//
//  Created by Evangelos Pittas on 11/6/21.
//

#if canImport(ThreeDS_SDK)

import Foundation
import ThreeDS_SDK

extension Transaction {
    func buildThreeDSecureAuthData() throws -> ThreeDSSDKAuthDataProtocol {
        let transactionParameters = try self.getAuthenticationRequestParameters()
        let sdkAppId = transactionParameters.getSDKAppID()
        let sdkTransactionId = transactionParameters.getSDKTransactionId()
        let sdkMaxTimeout = 10
        let sdkEncData = transactionParameters.getDeviceData()
        let sdkEphemeralKey = transactionParameters.getSDKEphemeralPublicKey()
        let sdkReferenceNumber = transactionParameters.getSDKReferenceNumber()
        
        return ThreeDS.SDKAuthData(
            sdkAppId: sdkAppId,
            sdkTransactionId: sdkTransactionId,
            sdkTimeout: sdkMaxTimeout,
            sdkEncData: sdkEncData,
            sdkEphemPubKey: sdkEphemeralKey,
            sdkReferenceNumber: sdkReferenceNumber)
    }
}

#endif
