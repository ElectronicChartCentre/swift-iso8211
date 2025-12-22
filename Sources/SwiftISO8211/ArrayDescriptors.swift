//
//  File.swift
//  SwiftISO8211
//

import Foundation

struct ArrayDescriptors {
    
    let labels: [String]
    
    static func create(_ ad: String) -> ArrayDescriptors? {
        
        // stupid simple way to handle \\
        let ad = ad.replacingOccurrences(of: "\\\\", with: "!")
        
        var labels: [String] = []
        var currentLabel = ""
        for character in ad {
            switch character {
            case "!":
                labels.append(currentLabel)
                currentLabel = ""
                continue
            default:
                currentLabel.append(String(character))
            }
        }
        
        if currentLabel.isEmpty == false {
            labels.append(currentLabel)
        }
        
        return ArrayDescriptors(labels: labels)
    }
    
}
