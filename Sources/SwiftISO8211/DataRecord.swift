//
//  File.swift
//  SwiftISO8211
//

import Foundation

public struct DataRecord {
     
    let leader: LogicalRecordLeader
    let directory: LogicalRecordDirectory
    public let fieldNodes: [FieldNode]
    
    public func fieldNodes(withTag tag: String) -> [FieldNode] {
        return fieldNodes.filter { $0.fieldTag == tag }
    }
    
    public static func create(reader: BinaryReader, ddr: DataDescriptiveRecord) -> DataRecord? {
        
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
            
            guard let arrayDescriptorsFormatControlsPair = ddr.arrayDescriptorsFormatControlsByTag[tag] else {
                return nil
            }
            let arrayDescriptors = arrayDescriptorsFormatControlsPair.0
            let formatControls = arrayDescriptorsFormatControlsPair.1
            
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
            var repeatsFieldValueByLabel: [[String: Any]] = []
            var repeatFieldValueByLabel: [String: Any] = [:]

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
                    // figure out if add as repeat or main field
                    if hasRepeat, arrayDescriptors.repetitionIndex ?? 0 > 0 {
                        repeatFieldValueByLabel[label] = value
                    } else {
                        fieldValueByLabel[label] = value
                    }
                }
            }
            
            if !repeatFieldValueByLabel.isEmpty {
                repeatsFieldValueByLabel.append(repeatFieldValueByLabel)
            }
            
            var repeatsFieldNodes: [FieldNode] = []
            if hasRepeat {
                while (reader.pos() + 1) < fieldEndPos {
                    var repeatFieldValueByLabel: [String: Any] = [:]
                    for (label, formatControl) in repeats {
                        let value = formatControl.readAny(reader: reader)
                        //print("DEBUG: DataRecord. tag \(tag), label: \(label), (repeat) value: \(String(describing: value)), fc: \(formatControl.string)")
                        if let value = value {
                            repeatFieldValueByLabel[label] = value
                        }
                    }
                    let fieldNode = FieldNode(fieldTag: tag, valueByLabel: repeatFieldValueByLabel, children: [])
                    repeatsFieldNodes.append(fieldNode)
                    repeatsFieldValueByLabel.append(repeatFieldValueByLabel)
                }
            }
            
            // figure out if repetition field nodes are to be appended to main or if they are children
            if !repeatsFieldNodes.isEmpty, arrayDescriptors.repetitionIndex ?? 0 > 0 {
                let fieldNode = FieldNode(fieldTag: tag, valueByLabel: fieldValueByLabel, children: repeatsFieldValueByLabel)
                fieldNodes.append(fieldNode)
            } else {
                let fieldNode = FieldNode(fieldTag: tag, valueByLabel: fieldValueByLabel, children: [])
                fieldNodes.append(fieldNode)
                fieldNodes.append(contentsOf: repeatsFieldNodes)
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
