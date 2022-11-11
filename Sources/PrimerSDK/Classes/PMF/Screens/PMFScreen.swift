//
//  PMFScreen.swift
//  PrimerSDK
//
//  Created by Evangelos on 1/11/22.
//

#if canImport(UIKit)

import Foundation

extension PMF.Screen {
    
    internal enum Orientation: String, Codable {
        case vertical = "VERTICAL"
        case horizontal = "HORIZONTAL"
    }
}

extension PMF {
    
    internal class Screen: Codable {
        
        var id: String
        var isBackButtonEnabled: Bool
        var isShareButtonEnabled: Bool
        var orientation: PMF.Screen.Orientation
        var components: [PMF.Component]
        
        private enum CodingKeys : String, CodingKey {
            case id
            case isBackButtonEnabled
            case isShareButtonEnabled
            case orientation
            case components
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            
            if let isBackButtonEnabled = try? container.decode(Bool.self, forKey: .isBackButtonEnabled) {
                self.isBackButtonEnabled = isBackButtonEnabled
            } else {
                self.isBackButtonEnabled = true
            }
            
            if let isShareButtonEnabled = try? container.decode(Bool.self, forKey: .isShareButtonEnabled) {
                self.isShareButtonEnabled = isShareButtonEnabled
            } else {
                self.isShareButtonEnabled = false
            }
                        
            self.orientation = try container.decode(PMF.Screen.Orientation.self, forKey: .orientation)
            
            do {
                self.components = try container.decode([PMF.Component].self, forKey: .components)
            } catch {
                throw error
            }
            
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.isBackButtonEnabled, forKey: .isBackButtonEnabled)
            try container.encode(self.orientation, forKey: .orientation)
            try container.encode(self.components, forKey: .components)
        }
    }
}

#endif
