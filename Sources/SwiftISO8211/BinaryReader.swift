//
//  File.swift
//  SwiftISO8211
//

import Foundation

public protocol BinaryReader {
    
    func hasMore() -> Bool
    
    func pos() -> Int
    
    func skip(numBytes: Int)
    
    func peekByte() -> UInt8?
    
    func readData(numBytes: Int) -> Data?
    
    func readString(numBytes: Int) -> String?
    
    func readStringUT() -> String?
    
    func readStringUT(maxPos: Int) -> String?
    
    func readStringFT() -> String?
    
    func readStringFT(maxPos: Int) -> String?
    
    func readAsciiUInt8(numBytes: Int) -> UInt8?
    
    func readAsciiUInt32(numBytes: Int) -> UInt32?
    
    func readAsciiUInt64(numBytes: Int) -> UInt64?
    
}

public class DataReader: BinaryReader {
    
    private let data: Data
    private var _pos: Int = 0
    
    public init(data: Data) {
        self.data = data
    }
    
    public func hasMore() -> Bool {
        return _pos < data.count
    }
    
    public func pos() -> Int {
        return _pos
    }
    
    public func skip(numBytes: Int) {
        if numBytes < 0 {
            print("ERROR: skip negative number of bytes?")
            return
        }
        if numBytes == 0 {
            print("DEBUG: skip 0 bytes. seem to be on track.")
            return
        }
        _pos = min(_pos + numBytes, data.count)
    }
    
    public func peekByte() -> UInt8? {
        guard _pos < data.count else {
            return nil
        }
        
        return data[data.index(data.startIndex, offsetBy: _pos)]
    }
    
    public func readData(numBytes: Int) -> Data? {
        if _pos + numBytes > data.count {
            print("ERROR: cannot read \(numBytes) bytes, only \(data.count - _pos) left.")
            return nil
        }
        let subData = data.subdata(in: _pos..<(_pos + numBytes))
        _pos += numBytes
        return subData
    }
    
    public func readString(numBytes: Int) -> String? {
        guard let subData = readData(numBytes: numBytes) else {
            return nil
        }
        let string = String(data: subData, encoding: .utf8) ?? ""
        return string
    }
    
    public func readStringUT() -> String? {
        return readString(maxPos: nil, terminator: Terminator.unit)
    }
    
    public func readStringUT(maxPos: Int) -> String? {
        return readString(maxPos: maxPos, terminator: Terminator.unit)
    }
    
    public func readStringFT() -> String? {
        return readString(maxPos: nil, terminator: Terminator.field)
    }
    
    public func readStringFT(maxPos: Int) -> String? {
        return readString(maxPos: maxPos, terminator: Terminator.field)
    }

    public func readString(maxPos: Int?, terminator: UInt8) -> String? {
        var string = ""
        while (_pos < data.count) {
            if let maxPos = maxPos, _pos >= maxPos {
                return string
            }
            if peekByte() == terminator {
                return string
            }

            guard let c = readString(numBytes: 1) else {
                print("DEBUG: could not read string from byte: \(peekByte().map(\.description) ?? "nil")")
                return nil
            }
            
            if c == "\0" {
                print("DEBUG: terminate string at null character. \(string)")
                return string
            }
            
            string.append(c)
        }
        return nil
    }
    
    public func readAsciiUInt8(numBytes: Int) -> UInt8? {
        guard let string = readString(numBytes: numBytes) else {
            return nil
        }
        
        guard let value = UInt8(string) else {
            print("ERROR: can not parse '\(string)' as UInt8")
            return nil
        }
        
        return value
    }
    
    public func readAsciiUInt32(numBytes: Int) -> UInt32? {
        guard let string = readString(numBytes: numBytes) else {
            return nil
        }
        
        guard let value = UInt32(string) else {
            print("ERROR: can not parse '\(string)' as UInt32")
            return nil
        }
        
        return value
    }
    
    public func readAsciiUInt64(numBytes: Int) -> UInt64? {
        guard let string = readString(numBytes: numBytes) else {
            return nil
        }
        
        guard let value = UInt64(string) else {
            print("ERROR: can not parse '\(string)' as UInt64")
            return nil
        }
        
        return value
    }
    
}
