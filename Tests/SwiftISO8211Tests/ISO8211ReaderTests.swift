//
//  Test.swift
//  SwiftISO8211
//

import Testing
import Foundation
import ZipArchive
@testable import SwiftISO8211

struct ISO8211ReaderTests {

    @Test func testS57() async throws {

        // this is an old NOAA S-57 ENC file with at least one record with record length 0 meaning over 99999 bytes.
        guard let testDataURL = Bundle.module.url(forResource: "TestResources/US4CN21M", withExtension: "000") else {
            Issue.record("Could not load test data")
            return
        }
        
        let reader = DataReader(data: try Data(contentsOf: testDataURL))
        
        let ddr = DataDescriptiveRecord.create(reader: reader)
        #expect(ddr != nil)
        #expect(ddr!.leader.recordLength == 1582)
        #expect(ddr!.leader.leaderIdentifier == "L")
        #expect(ddr!.leader.interchangeLevel == "3")
        #expect(ddr!.leader.versionNumber == "1")
        #expect(ddr!.leader.sizeOfFieldLengthField == 3)
        #expect(ddr!.leader.sizeOfFieldPositionField == 4)
        #expect(ddr!.leader.sizeOfFieldTagField == 4)
        #expect(ddr!.leader.sizeOfFieldEntry() == 11)
        #expect(ddr!.leader.reserved == 0)
        #expect(ddr!.directory.entries.count == 16)
        #expect(ddr!.arrayDescriptorss.count == 16)
        #expect(ddr!.formatControlss.count == 16)

        let rec1 = DataRecord.create(reader: reader, ddr: ddr!)
        #expect(rec1 != nil)
        #expect(rec1!.leader.recordLength == 143)
        #expect(rec1!.leader.leaderIdentifier == "D")
        #expect(rec1!.leader.interchangeLevel == " ")
        #expect(rec1!.leader.versionNumber == " ")
        #expect(rec1!.leader.sizeOfFieldLengthField == 2)
        #expect(rec1!.leader.sizeOfFieldPositionField == 2)
        #expect(rec1!.leader.sizeOfFieldTagField == 4)
        #expect(rec1!.leader.sizeOfFieldEntry() == 8)
        #expect(rec1!.leader.reserved == 0)
        #expect(rec1!.directory.entries.count == 3)
        #expect(rec1!.directory.entries[0].fieldTag == "0001")
        #expect(rec1!.directory.entries[1].fieldTag == "DSID")
        #expect(rec1!.directory.entries[2].fieldTag == "DSSI")

        var dataRecords: [DataRecord] = []
        dataRecords.append(rec1!)
        while reader.hasMore() {
            guard let record = DataRecord.create(reader: reader, ddr: ddr!) else {
                break
            }
            dataRecords.append(record)
        }
        #expect(dataRecords.count == 6283)
    }
    
    @Test func testS101() async throws {

        // from https://github.com/iho-ohi/S-101-Test-Datasets/blob/main/S-101_Test_DataSets/cells/101AA00DS0003/9/101AA00DS0003.000
        guard let testDataURL = Bundle.module.url(forResource: "TestResources/101AA00DS0003", withExtension: "000") else {
            Issue.record("Could not load test data")
            return
        }
        
        let reader = DataReader(data: try Data(contentsOf: testDataURL))
        
        let ddr = DataDescriptiveRecord.create(reader: reader)
        #expect(ddr != nil)
        #expect(ddr!.leader.recordLength == 2232)
        #expect(ddr!.leader.leaderIdentifier == "L")
        #expect(ddr!.leader.interchangeLevel == "3")
        #expect(ddr!.leader.versionNumber == "1")
        #expect(ddr!.leader.sizeOfFieldLengthField == 3)
        #expect(ddr!.leader.sizeOfFieldPositionField == 4)
        #expect(ddr!.leader.sizeOfFieldTagField == 4)
        #expect(ddr!.leader.sizeOfFieldEntry() == 11)
        #expect(ddr!.leader.reserved == 0)
        #expect(ddr!.directory.entries.count == 26)
        #expect(ddr!.arrayDescriptorss.count == 26)
        #expect(ddr!.formatControlss.count == 26)

        let rec1 = DataRecord.create(reader: reader, ddr: ddr!)
        #expect(rec1 != nil)
        #expect(rec1!.leader.recordLength == 1286)
        #expect(rec1!.leader.leaderIdentifier == "D")
        #expect(rec1!.leader.interchangeLevel == " ")
        #expect(rec1!.leader.versionNumber == " ")
        #expect(rec1!.leader.sizeOfFieldLengthField == 3)
        #expect(rec1!.leader.sizeOfFieldPositionField == 4)
        #expect(rec1!.leader.sizeOfFieldTagField == 4)
        #expect(rec1!.leader.sizeOfFieldEntry() == 11)
        #expect(rec1!.leader.reserved == 0)
        #expect(rec1!.directory.entries.count == 7)
        #expect(rec1!.directory.entries[0].fieldTag == "DSID")
        #expect(rec1!.directory.entries[1].fieldTag == "DSSI")
        #expect(rec1!.directory.entries[2].fieldTag == "ATCS")
        #expect(rec1!.fieldNodes(withTag: "DSID").count == 1)
        #expect(rec1!.fieldNodes(withTag: "DSID").first?.valueByLabel["DSNM"] as? String == "101AA00DS0003.000")
        #expect(rec1!.fieldNodes(withTag: "DSID").first?.valueByLabel["DSTC"] == nil)
        #expect(rec1!.fieldNodes(withTag: "DSID").first?.valueByLabel["*DSTC"] == nil)
        #expect(rec1!.fieldNodes(withTag: "DSID").first?.children.count == 2)
        #expect(rec1!.fieldNodes(withTag: "DSID").first?.children.first?.count == 1)
        #expect(rec1!.fieldNodes(withTag: "DSID").first?.children.last?.count == 1)
        #expect(rec1!.fieldNodes(withTag: "DSID").first?.children.first?["*DSTC"] as? Int == 14)
        #expect(rec1!.fieldNodes(withTag: "DSID").first?.children.last?["*DSTC"] as? Int == 18)
        #expect(rec1!.fieldNodes(withTag: "DSSI").count == 1)
        
        let rec2 = DataRecord.create(reader: reader, ddr: ddr!)
        #expect(rec2 != nil)
        #expect(rec2!.leader.recordLength == 151)
        #expect(rec2!.directory.entries.count == 5)
        #expect(rec2!.directory.entries[0].fieldTag == "CSID")
        #expect(rec2!.directory.entries[1].fieldTag == "CRSH")
        #expect(rec2!.directory.entries[2].fieldTag == "CRSH")
        #expect(rec2!.directory.entries[3].fieldTag == "CSAX")
        #expect(rec2!.directory.entries[4].fieldTag == "VDAT")

        var dataRecords: [DataRecord] = []
        dataRecords.append(rec1!)
        dataRecords.append(rec2!)
        while reader.hasMore() {
            guard let record = DataRecord.create(reader: reader, ddr: ddr!) else {
                break
            }
            dataRecords.append(record)
        }
        #expect(dataRecords.count == 190)
    }
    
    @Test func testParseCASeaTrialsS101Data() async throws {
        // download CA SeaTrials data. Do not include in this repo as of distribution agreement.
        let localZipFilePath = "ca-sea-trials.zip"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: localZipFilePath) {
            print("DEBUG: could not find \(localZipFilePath) locally, so try to download")
            guard let zipURL = URL(string: "https://www.charts.gc.ca/documents/data-gestion/Unencrypted_S100_DatasetsNov2025.zip") else {
                Issue.record("Invalid test data url")
                return
            }
            
            let (data, response) = try await URLSession.shared.data(from: zipURL)
            #expect((response as? HTTPURLResponse)?.statusCode == 200)
            #expect(data.count > 0)
            
            try data.write(to: URL(fileURLWithPath: localZipFilePath))
        }
        
        let zipData = try Data(contentsOf: URL(fileURLWithPath: localZipFilePath))
        
        var fileDataByName: [String: Data] = [:]
        let reader = try ZipArchiveReader(buffer: zipData)
        for fileHeader in try reader.readDirectory() {
            if fileHeader.isDirectory {
                continue
            }
            guard let filename = fileHeader.filename.lastComponent?.string else {
                continue
            }
            if !filename.hasPrefix("101") || !filename.hasSuffix(".000") {
                continue
            }
            let fileContents = Data(try reader.readFile(fileHeader))
            fileDataByName[filename] = fileContents
        }
        
        #expect(!fileDataByName.isEmpty)
        
        for (fileName, data) in fileDataByName {
            print("DEBUG: start reading \(fileName)")
            let reader = DataReader(data: data)
            
            guard let ddr = DataDescriptiveRecord.create(reader: reader) else {
                Issue.record("Could not parse \(fileName) as a ISO8211 file")
                return
            }

            var dataRecords: [DataRecord] = []
            while reader.hasMore() {
                guard let record = DataRecord.create(reader: reader, ddr: ddr) else {
                    Issue.record("Could not parse \(fileName) as a ISO8211 file - record \(dataRecords.count + 1)")
                    return
                }
                dataRecords.append(record)
            }

            #expect(dataRecords.count > 0)
            
            for record in dataRecords {
                for fieldNode in record.fieldNodes(withTag: "C3IL") {
                    #expect(fieldNode.children.isEmpty == false)
                }
            }
        }
        
    }


}
