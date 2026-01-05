//
//  File.swift
//  SwiftISO8211
//

import Foundation

public struct DataDescriptiveRecord {
    
    let leader: LogicalRecordLeader
    let directory: LogicalRecordDirectory
    
    let arrayDescriptorss: [ArrayDescriptors]
    let formatControlss: [FormatControls]
    
    let arrayDescriptorsFormatControlsByTag: [String: (ArrayDescriptors, FormatControls)]
    
    init(leader: LogicalRecordLeader, directory: LogicalRecordDirectory, arrayDescriptorss: [ArrayDescriptors], formatControlss: [FormatControls]) {
        self.leader = leader
        self.directory = directory
        self.arrayDescriptorss = arrayDescriptorss
        self.formatControlss = formatControlss

        // combine in directory for faster and easier lookup
        var arrayDescriptorsFormatControlsByTag: [String: (ArrayDescriptors, FormatControls)] = [:]
        for (index, directoryEntry) in directory.entries.enumerated() {
            let arrayDescriptors = arrayDescriptorss[index]
            let formatControls = formatControlss[index]
            arrayDescriptorsFormatControlsByTag[directoryEntry.fieldTag] = (arrayDescriptors, formatControls)
        }
        self.arrayDescriptorsFormatControlsByTag = arrayDescriptorsFormatControlsByTag
    }
    
    public static func create(reader: BinaryReader) -> DataDescriptiveRecord? {
        
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
            
            // field controls
            guard let _ = reader.readString(numBytes: fieldControlLength) else {
                return nil
            }
            
            // data field name
            guard let _ = reader.readStringUT(maxPos: fieldEnd) else {
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
