//
//  ReadANCUnitTests.swift
//  Nothing X MacOSTests
//
//  Created by Daniel on 2025/3/14.
//

import XCTest
@testable import Nothing_X_MacOS
import os
final class ReadANCUnitTests: XCTestCase {
    
    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "nothing service")
    func testReadANC_ValidInput() throws {
        
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x05]
        let result = try NothingServiceImpl.readANC(hexArray: hexArray, logger: logger)
        XCTAssertEqual(result, ANC.OFF)
        
    }
    
    func testReadANC_InvalidInput_LengthError() {
        
        let hexArray: [UInt8] = [0x00, 0x01, 0x02]
        XCTAssertThrowsError(try NothingServiceImpl.readANC(hexArray: hexArray, logger: logger)) { error in
            XCTAssertEqual(error as? ArrayErrors, ArrayErrors.rangeError("hexArray length is less than 10"))
        }
    }
    
    func testReadANC_InvalidInput_InvalidANCValue() {
        
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0xFF, 0xFF]
        XCTAssertThrowsError(try NothingServiceImpl.readANC(hexArray: hexArray, logger: logger)) { error in
            XCTAssertEqual(error as? Errors, Errors.invalidArgument("failed to parse anc mode"))
        }
    }
    

    
}
