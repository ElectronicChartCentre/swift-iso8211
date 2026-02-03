# Swift ISO-8211 parser

## Introduction

ISO-8211 is a format used by electronic nautical charts like S-57 ENC and S-101. This repo has a Swift Package that can parse ISO-8211 files.

To use S-57 ENC and S-101 for anything, much more than this library is needed.

## How to use

```swift
        import SwiftISO8211

        let reader = DataReader(data: try Data(contentsOf: testDataURL))
        
        let ddr = DataDescriptiveRecord.create(reader: reader)
        while reader.hasMore() {
            let record = DataRecord.create(reader: reader, ddr: ddr!)
        }
```
## Build status

[![Swift](https://github.com/ElectronicChartCentre/swift-iso8211/actions/workflows/swift.yml/badge.svg)](https://github.com/ElectronicChartCentre/swift-iso8211/actions/workflows/swift.yml)
