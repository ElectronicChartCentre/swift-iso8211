//
//  File.swift
//  SwiftISO8211
//

import Foundation

struct ArrayDescriptors {

  let labels: [String]
  let repetitionIndex: Int?

  init(labels: [String]) {
    self.labels = labels

    var repetitionIndex: Int? = nil
    for (index, label) in labels.enumerated() {
      if label.hasPrefix("*") {
        repetitionIndex = index
        break
      }
    }
    self.repetitionIndex = repetitionIndex
  }

  func hasRepetition() -> Bool {
    return repetitionIndex != nil
  }

  func repetitionGroupCount() -> Int? {
    if let ri = repetitionIndex {
      return labels.count - ri
    }
    return nil
  }

  static func create(_ ad: String) -> ArrayDescriptors? {

    // stupid simple way to handle \\
    let ad = ad.replacingOccurrences(of: "\\\\", with: "!")

    var labels: [String] = []
    var currentLabel = ""
    for character in ad {
      switch character {
      case "!":
        labels.append(currentLabel)
        currentLabel = ""
        continue
      default:
        currentLabel.append(String(character))
      }
    }

    if currentLabel.isEmpty == false {
      labels.append(currentLabel)
    }

    return ArrayDescriptors(labels: labels)
  }

}
