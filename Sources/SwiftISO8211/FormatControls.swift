//
//  File.swift
//  SwiftISO8211
//

import Foundation

struct FormatControls {
    
    let formatControls: [FormatControl]
    
    static func create(_ fc: String) -> FormatControls? {
        
        if fc.isEmpty {
            return FormatControls(formatControls: [])
        }
        
        var elements: [String] = []
        var currentPart = ""
        
        // split and figure what paranteses to skip and keep
        for character in fc {
            switch character {
            case ",":
                elements.append(currentPart)
                currentPart = ""
            case "(":
                if currentPart.isEmpty {
                    continue
                } else {
                    currentPart.append(character)
                }
            case ")":
                if !currentPart.isEmpty, currentPart.contains("("), !currentPart.contains(")") {
                    currentPart.append(character)
                } else {
                    continue
                }
            default:
                currentPart.append(character)
            }
        }
        
        if !currentPart.isEmpty {
            elements.append(currentPart)
        }

        // explode by count part
        var formatControls: [FormatControl] = []
        for element in elements {
            var countPart = ""
            var formatPart = ""
            for character in element {
                if formatPart.isEmpty, character >= "0", character <= "9" {
                    countPart.append(character)
                } else {
                    formatPart.append(character)
                }
            }
            
            if countPart.isEmpty {
                formatControls.append(FormatControl(string: String(element)))
            } else {
                for _ in 0..<Int(countPart)! {
                    formatControls.append(FormatControl(string: formatPart))
                }
            }
        }
        
        return FormatControls(formatControls: formatControls)
    }
    
}

struct FormatControl {
    
    let string: String
    
    private let numBytes: Int?
    
    private let byteOrder: __CFByteOrder
    
    // 1 for unsigned int, 2 signed int, 3 real fixed, 4 real floating, 5 complex floating
    private let numberType: Int?
    
    private let octetCount: Int?
    
    init(string: String) {
        self.string = string
        
        if (string.hasPrefix("A(") || string.hasPrefix("R(")), string.hasSuffix(")") {
            numBytes = Int(string.dropFirst(2).dropLast())
        } else if string.hasPrefix("B("), string.hasSuffix(")") {
            if let numBits = Int(string.dropFirst(2).dropLast()) {
                numBytes = numBits / 8
            } else {
                numBytes = nil
            }
        } else {
            numBytes = nil
        }
        
        if (string.hasPrefix("b") || string.hasPrefix("B")), string.count == 3 {
            let parts = Array(string)
            
            // b14
            // first is byte order. B is MSOF, b is LSOF
            // second is 1 for unsigned int, 2 signed int, 3 real fixed, 4 real floating, 5 complex floating
            // third is number of octets. 1,2,3,4 for ints. 4,8 for real/float.
            
            byteOrder = string.hasPrefix("b") ? CFByteOrderLittleEndian : CFByteOrderBigEndian
            numberType = Int(String(parts[1]))
            octetCount = Int(String(parts[2]))!
        } else {
            byteOrder = CFByteOrderUnknown
            numberType = nil
            octetCount = nil
        }
    }
    
    func readAny(reader: BinaryReader) -> Any? {
        
        if string.hasPrefix("A") || string.hasPrefix("R") {
            if let value = readString(reader: reader) {
                return value
            }
        }
        
        if let numberType = numberType, numberType == 4, let octetCount = octetCount {
            return readFloat(reader: reader)
        }

        
        if string.hasPrefix("B") {
            if let value = readData(reader: reader) {
                return value
            }
        }
        
        if let value = readInt(reader: reader) {
            return value
        }
        
        return nil
    }
    
    func readString(reader: BinaryReader) -> String? {
        
        if string == "A" {
            let string = reader.readStringUT()
            if string != nil {
                reader.skip(numBytes: 1)
            }
            return string
        }
        
        if let stringLength = numBytes {
            return reader.readString(numBytes: stringLength)
        }
        
        print("DEBUG: can not read string with format control: \(string)")
        return nil
    }
    
    func readInt(reader: BinaryReader) -> Int? {
        
        guard let numberType = numberType, let octetCount = octetCount else {
            return nil
        }
        
        guard let data = reader.readData(numBytes: octetCount) else {
            print("DEBUG: can not read int with format control: \(string)")
            return nil
        }
        
        if numberType == 1 {
            if octetCount == 1 {
                return Int(UInt8(data[0]))
            }
            if octetCount == 2 {
                return data.withUnsafeBytes { ptr in
                    if ptr.count == MemoryLayout<UInt16>.size {
                        var value = ptr.load(as: UInt16.self)
                        if CFByteOrderGetCurrent() != byteOrder.rawValue {
                            value = value.byteSwapped
                        }
                        return Int(value)
                    }
                    print("ERROR: size of UInt16 does not match")
                    return 0
                }
            }
            if octetCount == 4 {
                return data.withUnsafeBytes { ptr in
                    if ptr.count == MemoryLayout<UInt32>.size {
                        var value = ptr.load(as: UInt32.self)
                        if CFByteOrderGetCurrent() != byteOrder.rawValue {
                            value = value.byteSwapped
                        }
                        return Int(value)
                    }
                    print("ERROR: size of UInt32 does not match")
                    return 0
                }
            }
        } else if numberType == 2 {
            if octetCount == 1 {
                return Int(Int8(data[0]))
            }
            if octetCount == 2 {
                return data.withUnsafeBytes { ptr in
                    if ptr.count == MemoryLayout<Int16>.size {
                        var value = ptr.load(as: Int16.self)
                        if CFByteOrderGetCurrent() != byteOrder.rawValue {
                            value = value.byteSwapped
                        }
                        return Int(value)
                    }
                    print("ERROR: size of Int16 does not match")
                    return 0
                }
            }
            if octetCount == 4 {
                return data.withUnsafeBytes { ptr in
                    if ptr.count == MemoryLayout<Int32>.size {
                        var value = ptr.load(as: Int32.self)
                        if CFByteOrderGetCurrent() != byteOrder.rawValue {
                            value = value.byteSwapped
                        }
                        return Int(value)
                    }
                    print("ERROR: size of Int32 does not match")
                    return 0
                }
            }
        }
        
        print("DEBUG: can not read int with format control: \(string)")
        return nil
    }
    
    func readFloat(reader: BinaryReader) -> Float? {
        
        guard let numberType = numberType, numberType == 4, let octetCount = octetCount else {
            return nil
        }
        
        guard let data = reader.readData(numBytes: octetCount) else {
            print("DEBUG: can not read int with format control: \(string)")
            return nil
        }
        
        if octetCount == 4 {
            return data.withUnsafeBytes { ptr in
                if ptr.count == MemoryLayout<UInt32>.size {
                    var uint32value = ptr.load(as: UInt32.self)
                    if CFByteOrderGetCurrent() != byteOrder.rawValue {
                        uint32value = uint32value.byteSwapped
                    }
                    return Float32(bitPattern: uint32value)
                }
                print("ERROR: size of Float32 does not match")
                return 0
            }
        }
        if octetCount == 8 {
            return data.withUnsafeBytes { ptr in
                if ptr.count == MemoryLayout<UInt64>.size {
                    var uint64value = ptr.load(as: UInt64.self)
                    if CFByteOrderGetCurrent() != byteOrder.rawValue {
                        uint64value = uint64value.byteSwapped
                    }
                    return Float(Float64(bitPattern: uint64value))
                }
                print("ERROR: size of Float64 does not match")
                return 0
            }
        }
        
        print("DEBUG: can not read float with format control: \(string)")
        return nil
    }
    
    func readData(reader: BinaryReader) -> Data? {
        if let numBytes = numBytes {
            return reader.readData(numBytes: numBytes)
        }
        return nil
    }
    
}
