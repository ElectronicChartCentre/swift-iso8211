//
//  File.swift
//  SwiftISO8211
//

import Foundation

public struct FieldNode {
    
    public let fieldTag: String
    public let valueByLabel: [String: Any]
    public let children: [[String: Any]]
    
}
