//
//  File.swift
//  SwiftISO8211
//

import Foundation

struct LogicalRecordLeader {

  let recordLength: UInt64
  let interchangeLevel: String
  let leaderIdentifier: String
  let inlineCodeExtensionIndicator: String
  let versionNumber: String
  let applicationIndicator: String
  let fieldControlLength: String
  let baseAddressOfFieldData: UInt64
  let extendedCharacterSetIndicator: String
  let sizeOfFieldLengthField: UInt8
  let sizeOfFieldPositionField: UInt8
  let reserved: UInt8
  let sizeOfFieldTagField: UInt8

  func sizeOfFieldEntry() -> UInt32 {
    return UInt32(sizeOfFieldLengthField) + UInt32(sizeOfFieldPositionField)
      + UInt32(sizeOfFieldTagField)
  }

  static func create(reader: BinaryReader) -> LogicalRecordLeader? {
    guard let recordLength = reader.readAsciiUInt64(numBytes: 5) else {
      return nil
    }
    guard let interchangeLevel = reader.readString(numBytes: 1) else {
      return nil
    }
    guard let leaderIdentifier = reader.readString(numBytes: 1) else {
      return nil
    }
    guard let inlineCodeExtensionIndicator = reader.readString(numBytes: 1) else {
      return nil
    }
    guard let versionNumber = reader.readString(numBytes: 1) else {
      return nil
    }
    guard let applicationIndicator = reader.readString(numBytes: 1) else {
      return nil
    }
    guard let fieldControlLength = reader.readString(numBytes: 2) else {
      return nil
    }
    guard let baseAddressOfFieldData = reader.readAsciiUInt64(numBytes: 5) else {
      return nil
    }
    guard let extendedCharacterSetIndicator = reader.readString(numBytes: 3) else {
      return nil
    }
    guard let sizeOfFieldLengthField = reader.readAsciiUInt8(numBytes: 1) else {
      return nil
    }
    guard let sizeOfFieldPositionField = reader.readAsciiUInt8(numBytes: 1) else {
      return nil
    }
    guard let reserved = reader.readAsciiUInt8(numBytes: 1) else {
      return nil
    }
    guard let sizeOfFieldTagField = reader.readAsciiUInt8(numBytes: 1) else {
      return nil
    }

    return LogicalRecordLeader(
      recordLength: recordLength, interchangeLevel: interchangeLevel,
      leaderIdentifier: leaderIdentifier,
      inlineCodeExtensionIndicator: inlineCodeExtensionIndicator, versionNumber: versionNumber,
      applicationIndicator: applicationIndicator, fieldControlLength: fieldControlLength,
      baseAddressOfFieldData: baseAddressOfFieldData,
      extendedCharacterSetIndicator: extendedCharacterSetIndicator,
      sizeOfFieldLengthField: sizeOfFieldLengthField,
      sizeOfFieldPositionField: sizeOfFieldPositionField, reserved: reserved,
      sizeOfFieldTagField: sizeOfFieldTagField)
  }

}
