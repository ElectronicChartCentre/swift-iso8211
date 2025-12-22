//
//  File.swift
//  SwiftISO8211
//

import Foundation

struct DataDescriptiveRecord {
    
    let leader: LogicalRecordLeader
    let directory: LogicalRecordDirectory
    
    let arrayDescriptorss: [ArrayDescriptors]
    let formatControlss: [FormatControls]
    
    func arrayDescriptors(forFieldWithTag tag: String) -> ArrayDescriptors? {
        guard let idx = directory.entryIndex(tag: tag) else {
            return nil
        }
        return arrayDescriptorss[idx]
    }
    
    func formatControls(forFieldWithTag tag: String) -> FormatControls? {
        guard let idx = directory.entryIndex(tag: tag) else {
            return nil
        }
        return formatControlss[idx]
    }
    
    static func create(reader: BinaryReader) -> DataDescriptiveRecord? {
        
        guard let leader = LogicalRecordLeader.create(reader: reader) else {
            return nil
        }
        
        guard let directory = LogicalRecordDirectory.create(reader: reader, leader: leader) else {
            return nil
        }
        
        var arrayDescriptorss: [ArrayDescriptors] = []
        var formatControlss: [FormatControls] = []
        
        for entry in directory.entries {
            let fieldEnd = reader.pos() + Int(entry.fieldPosition + entry.fieldLength - 1)
            
            guard let fieldControlLength = Int(leader.fieldControlLength) else {
                return nil
            }
            guard let fieldControls = reader.readString(numBytes: fieldControlLength) else {
                return nil
            }
            
            guard let dataFieldName = reader.readStringUT(maxPos: fieldEnd) else {
                return nil
            }
            reader.skip(numBytes: 1)
            
            guard let arrayDescriptor = reader.readStringUT(maxPos: fieldEnd) else {
                return nil
            }
            reader.skip(numBytes: 1)
            
            guard let formatControls = reader.readStringFT(maxPos: fieldEnd) else {
                return nil
            }
            reader.skip(numBytes: 1)
            
            print("DEBUG: tag: \(entry.fieldTag), ad: \(arrayDescriptor), fc: \(formatControls)")
            
            guard let arrayDescriptors = ArrayDescriptors.create(arrayDescriptor) else {
                return nil
            }
            arrayDescriptorss.append(arrayDescriptors)
            
            guard let parsedFormatControls = FormatControls.create(formatControls) else {
                return nil
            }
            formatControlss.append(parsedFormatControls)
        }

        return DataDescriptiveRecord(leader: leader, directory: directory, arrayDescriptorss: arrayDescriptorss, formatControlss: formatControlss)
    }
    
}
