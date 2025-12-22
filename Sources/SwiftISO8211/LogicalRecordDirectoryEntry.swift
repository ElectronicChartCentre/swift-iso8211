//
//  File.swift
//  SwiftISO8211
//

import Foundation

struct LogicalRecordDirectoryEntry {
    
    let fieldTag: String
    let fieldLength: UInt32
    let fieldPosition: UInt32
    
    static func create(reader: BinaryReader, leader: LogicalRecordLeader) -> LogicalRecordDirectoryEntry? {
        
        guard let fieldTag = reader.readString(numBytes: Int(leader.sizeOfFieldTagField)) else {
            return nil
        }
        
        guard let fieldLength = reader.readAsciiUInt32(numBytes: Int(leader.sizeOfFieldLengthField)) else {
            return nil
        }
        
        guard let fieldPosition = reader.readAsciiUInt32(numBytes: Int(leader.sizeOfFieldPositionField)) else {
            return nil
        }
        
        // print("DEBUG: fieldTag: \(fieldTag), fieldLength: \(fieldLength), fieldPosition: \(fieldPosition)")
        
        return LogicalRecordDirectoryEntry(fieldTag: fieldTag, fieldLength: fieldLength, fieldPosition: fieldPosition)
    }
    
}
