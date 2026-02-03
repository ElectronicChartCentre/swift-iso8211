//
//  Test.swift
//  SwiftISO8211
//

import Testing

@testable import SwiftISO8211

struct FormatControlsTests {

  @Test func testS57DSID() async throws {
    let fc = FormatControls.create("(b11,b14,2b11,3A,2A(8),R(4),b11,2A,b11,b12,A)")
    #expect(fc != nil)
    #expect(fc!.formatControls.count == 16)
    #expect(fc!.formatControls[0].string == "b11")
    #expect(fc!.formatControls[1].string == "b14")
    #expect(fc!.formatControls[2].string == "b11")
    #expect(fc!.formatControls[3].string == "b11")
    #expect(fc!.formatControls[4].string == "A")
    #expect(fc!.formatControls[5].string == "A")
    #expect(fc!.formatControls[6].string == "A")
    #expect(fc!.formatControls[7].string == "A(8)")
    #expect(fc!.formatControls[8].string == "A(8)")
    #expect(fc!.formatControls[9].string == "R(4)")
    #expect(fc!.formatControls[10].string == "b11")
    #expect(fc!.formatControls[11].string == "A")
    #expect(fc!.formatControls[12].string == "A")
    #expect(fc!.formatControls[13].string == "b11")
    #expect(fc!.formatControls[14].string == "b12")
    #expect(fc!.formatControls[15].string == "A")
  }

  @Test func testS57ENCVRPT() async throws {
    let fc = FormatControls.create("(B(40),4b11)")
    #expect(fc != nil)
    #expect(fc!.formatControls.count == 5)
    #expect(fc!.formatControls[0].string == "B(40)")
    #expect(fc!.formatControls[1].string == "b11")
    #expect(fc!.formatControls[2].string == "b11")
    #expect(fc!.formatControls[3].string == "b11")
    #expect(fc!.formatControls[4].string == "b11")
  }

  @Test func testS101DSID() async throws {
    let fc = FormatControls.create("(b11,b14,7A,A(8),3A,(b11))")
    #expect(fc != nil)
    #expect(fc!.formatControls.count == 14)
    #expect(fc!.formatControls[12].string == "A")
    #expect(fc!.formatControls[13].string == "b11")
  }

  @Test func testS101INAS() async throws {
    let fc = FormatControls.create("(b11,b14,2b12,b11,(3b12,b11,A))")
    #expect(fc != nil)
    #expect(fc!.formatControls.count == 10)
    #expect(fc!.formatControls[0].string == "b11")
    #expect(fc!.formatControls[1].string == "b14")
    #expect(fc!.formatControls[2].string == "b12")
    #expect(fc!.formatControls[3].string == "b12")
    #expect(fc!.formatControls[4].string == "b11")
    #expect(fc!.formatControls[5].string == "b12")
    #expect(fc!.formatControls[6].string == "b12")
    #expect(fc!.formatControls[7].string == "b12")
    #expect(fc!.formatControls[8].string == "b11")
    #expect(fc!.formatControls[9].string == "A")
  }

}
