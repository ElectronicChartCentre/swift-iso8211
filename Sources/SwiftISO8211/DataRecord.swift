//
//  File.swift
//  SwiftISO8211
//

import Foundation

struct DataRecord {
    
    let leader: LogicalRecordLeader
    let directory: LogicalRecordDirectory
    let fieldNodes: [FieldNode]
    
    static func create(reader: BinaryReader, ddr: DataDescriptiveRecord) -> DataRecord? {
        
        // print("DEBUG: start read record")
        
        let recordStartPos = reader.pos()

        guard let leader = LogicalRecordLeader.create(reader: reader) else {
            return nil
        }
        
        // recordEndPos is not known if record length is 0
        let recordEndPos = leader.recordLength == 0 ? nil : recordStartPos + Int(leader.recordLength)
        
        guard let directory = LogicalRecordDirectory.create(reader: reader, leader: leader) else {
            return nil
        }
        
        var fieldNodes: [FieldNode] = []
        
        for directoryEntry in directory.entries {
            
            let tag = directoryEntry.fieldTag
            
            if tag == "0001" {
                reader.skip(numBytes: Int(directoryEntry.fieldLength))
                continue
            }
            
            guard let arrayDescriptors = ddr.arrayDescriptors(forFieldWithTag: tag) else {
                return nil
            }
            guard let formatControls = ddr.formatControls(forFieldWithTag: tag) else {
                return nil
            }
            
            if arrayDescriptors.labels.count != formatControls.formatControls.count {
                print("ERROR: tag \(tag). array descriptors count: \(arrayDescriptors.labels.count) does not match format controls count: \(formatControls.formatControls.count)")
                return nil
            }
            
            // why does skipping a single byte here help? what is that byte?
            reader.skip(numBytes: 1)
            
            let fieldEndPos = reader.pos() + Int(directoryEntry.fieldLength)
            
            // handle *tag type of repeats
            var repeats: [(label: String, formatControl: FormatControl)] = []
            var hasRepeat = false

            var fieldValueByLabel: [String: Any] = [:]
            for (label, formatControl) in zip(arrayDescriptors.labels, formatControls.formatControls) {
                
                if !hasRepeat, label.hasPrefix("*") {
                    
                    // if it is a \\* kind of label, then we might stop here. so check end.
                    if (reader.pos() + 1) == fieldEndPos {
                        break
                    }
                    
                    hasRepeat = true
                }
                if hasRepeat {
                    repeats.append((label: label, formatControl: formatControl))
                }

                let value = formatControl.readAny(reader: reader)
                //print("DEBUG: DataRecord. tag \(tag), label: \(label), value: \(String(describing: value)), fc: \(formatControl.string)")
                if let value = value {
                    fieldValueByLabel[label] = value
                }
            }
            let fieldNode = FieldNode(fieldTag: tag, valueByLabel: fieldValueByLabel)
            fieldNodes.append(fieldNode)

            if hasRepeat {
                while (reader.pos() + 1) < fieldEndPos {
                    var fieldValueByLabel: [String: Any] = [:]
                    for (label, formatControl) in repeats {
                        let value = formatControl.readAny(reader: reader)
                        //print("DEBUG: DataRecord. tag \(tag), label: \(label), (repeat) value: \(String(describing: value)), fc: \(formatControl.string)")
                        if let value = value {
                            fieldValueByLabel[label] = value
                        }
                    }
                    let fieldNode = FieldNode(fieldTag: tag, valueByLabel: fieldValueByLabel)
                    fieldNodes.append(fieldNode)
                }
            }
        }
        
        // check record end
        if reader.peekByte() == Terminator.field {
            // expected and good
            reader.skip(numBytes: 1)
        } else {
            // not good.
            print("ERROR: record end, but not at FT. reader at \(reader.pos()). expected \(String(describing: recordEndPos))")
            if let recordEndPos = recordEndPos {
                reader.skip(numBytes: recordEndPos - reader.pos())
            }
        }
        
        return DataRecord(leader: leader, directory: directory, fieldNodes: fieldNodes)
    }
    
}
