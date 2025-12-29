//
//  Test.swift
//  SwiftISO8211
//

import Testing
@testable import SwiftISO8211

struct Test {

    @Test func testS57ENCDSID() async throws {
        let ad = ArrayDescriptors.create("RCNM!RCID!EXPP!INTU!DSNM!EDTN!UPDN!UADT!ISDT!STED!PRSP!PSDN!PRED!PROF!AGEN!COMT")
        #expect(ad != nil)
        #expect(ad!.labels.count == 16)
        #expect(ad!.hasRepetition() == false)
    }
    
    @Test func testS57ENCFSPT() async throws {
        let ad = ArrayDescriptors.create("*NAME!ORNT!USAG!MASK")
        #expect(ad != nil)
        #expect(ad!.labels.count == 4)
        #expect(ad!.hasRepetition() == true)
        #expect(ad!.repetitionGroupCount() == 4)
    }

    @Test func testS57ENCVRPT() async throws {
        let ad = ArrayDescriptors.create("*NAME!ORNT!USAG!TOPI!MASK")
        #expect(ad != nil)
        #expect(ad!.labels.count == 5)
        #expect(ad!.hasRepetition() == true)
        #expect(ad!.repetitionGroupCount() == 5)
    }
    
    @Test func testS101DSID() async throws {
        let ad = ArrayDescriptors.create("RCNM!RCID!ENSP!ENED!PRSP!PRED!PROF!DSNM!DSTL!DSRD!DSLG!DSAB!DSED\\\\*DSTC")
        #expect(ad != nil)
        #expect(ad!.labels.count == 14)
        #expect(ad!.labels[12] == "DSED")
        #expect(ad!.labels[13] == "*DSTC")
        #expect(ad!.hasRepetition() == true)
        #expect(ad!.repetitionGroupCount() == 1)
    }

    @Test func testS101INAS() async throws {
        let ad = ArrayDescriptors.create("RRNM!RRID!NIAC!NARC!IUIN\\\\*NATC!ATIX!PAIX!ATIN!ATVL")
        #expect(ad != nil)
        #expect(ad!.labels.count == 10)
        #expect(ad!.labels[4] == "IUIN")
        #expect(ad!.labels[5] == "*NATC")
        #expect(ad!.hasRepetition() == true)
        #expect(ad!.repetitionGroupCount() == 5)
    }
    
}
