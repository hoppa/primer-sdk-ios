//
//  CreateClientToken.swift
//  PrimerSDK_Example
//
//  Created by Carl Eriksson on 08/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

// Merchants:
// Sandbox: demo@primer.test
// Staging: tester+01@primer.test
// Production: demo@primer.test

enum Environment: String, Codable {
    case dev, sandbox, staging, production
}

struct CreateClientTokenRequest: Codable {
    let customerId: String?
    let customerCountryCode: String?
    var environment: Environment = .sandbox
}

struct TransactionResponse {
    var id: String
    var date: String
    var status: String
    var requiredAction: [String: Any]
}
