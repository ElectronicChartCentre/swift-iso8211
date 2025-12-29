//
//  Test.swift
//  SwiftISO8211
//

import Testing
import Foundation
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

}
