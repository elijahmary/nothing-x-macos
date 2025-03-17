//
//  CRC16UnitTests.swift
//  Nothing X MacOSTests
//
//  Created by Daniel on 2025/3/15.
//

import XCTest
@testable import Nothing_X_MacOS
import os

final class CRC16UnitTests: XCTestCase {

    func testCrc16WithEmptyBuffer() {
         let buffer: [UInt8] = []
         let expectedCrc: UInt16 = 0xFFFF // Expected CRC for an empty buffer
         let result = CRC16.crc16(buffer: buffer)
         XCTAssertEqual(result, expectedCrc, "CRC16 for an empty buffer should be 0xFFFF")
     }
     
     func testCrc16WithSingleByte() {
         let buffer: [UInt8] = [0x01]
         let expectedCrc: UInt16 = 0xA001 // Expected CRC for the byte 0x01
         let result = CRC16.crc16(buffer: buffer)
         XCTAssertEqual(result, expectedCrc, "CRC16 for buffer [0x01] should be 0xA001")
     }
     
     func testCrc16WithMultipleBytes() {
         let buffer: [UInt8] = [0x01, 0x02, 0x03]
         let expectedCrc: UInt16 = 0xB001 // Expected CRC for the bytes [0x01, 0x02, 0x03]
         let result = CRC16.crc16(buffer: buffer)
         XCTAssertEqual(result, expectedCrc, "CRC16 for buffer [0x01, 0x02, 0x03] should be 0xB001")
     }
     
     func testCrc16WithKnownValues() {
         let testCases: [([UInt8], UInt16)] = [
             ([0x31, 0x32, 0x33], 0xA3D1), // ASCII for "123"
             ([0xFF, 0xFE, 0xFD], 0xB001), // Example case
             ([0x00, 0x00, 0x00], 0xFFFF)  // All zeros
         ]
         
         for (buffer, expectedCrc) in testCases {
             let result = CRC16.crc16(buffer: buffer)
             XCTAssertEqual(result, expectedCrc, "CRC16 for buffer \(buffer) should be \(String(format: "0x%04X", expectedCrc))")
         }
     }

}
