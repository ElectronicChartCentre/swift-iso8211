//
//  File.swift
//  SwiftISO8211
//

import Foundation

struct LogicalRecordDirectory {

  let entries: [LogicalRecordDirectoryEntry]

  func entryIndex(tag: String) -> Int? {
    return entries.map({ $0.fieldTag }).firstIndex(of: tag)
  }

  static func create(reader: BinaryReader, leader: LogicalRecordLeader) -> LogicalRecordDirectory? {

    var entries = [LogicalRecordDirectoryEntry]()
    while reader.peekByte() != Terminator.field {
      guard let entry = LogicalRecordDirectoryEntry.create(reader: reader, leader: leader) else {
        return nil
      }
      entries.append(entry)
    }

    return LogicalRecordDirectory(entries: entries)
  }

}
