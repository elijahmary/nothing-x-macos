//
//  ReadLatencyUnitTests.swift
//  Nothing X MacOSTests
//
//  Created by Daniel on 2025/3/14.
//

import XCTest
@testable import Nothing_X_MacOS
import os


final class ReadLatencyUnitTests: XCTestCase {
    
    
    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "nothing service")
    
    func testReadLatencyMode_ValidInputTrue() throws {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x01]
        let result = try NothingServiceImpl.readLatencyMode(hexArray: hexArray, logger: logger)
        XCTAssertTrue(result)
    }
    
    func testReadLatencyMode_ValidInputFalse() throws {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x02]
        let result = try NothingServiceImpl.readLatencyMode(hexArray: hexArray, logger: logger)
        XCTAssertFalse(result)
    }
    
    func testReadLatencyMode_InvalidInput() {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02]
        XCTAssertThrowsError(try NothingServiceImpl.readLatencyMode(hexArray: hexArray, logger: logger)) { error in
            XCTAssertEqual(error as? ArrayErrors, ArrayErrors.rangeError("hexArray length is less than 8"))
        }
    }
    
    func testReadLatencyMode_OtherValues() throws {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x03]
        let result = try NothingServiceImpl.readLatencyMode(hexArray: hexArray, logger: logger)
        XCTAssertFalse(result)
    }
    
    func testReadLatencyMode_Boundaries() throws {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0xFF]
        let result = try NothingServiceImpl.readLatencyMode(hexArray: hexArray, logger: logger)
        XCTAssertFalse(result)
    }
    
}
