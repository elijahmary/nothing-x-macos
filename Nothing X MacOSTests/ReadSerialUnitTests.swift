//
//  ReadSerialUnitTests.swift
//  Nothing X MacOSTests
//
//  Created by Daniel on 2025/3/14.
//

import XCTest

@testable import Nothing_X_MacOS
import os

final class ReadSerialUnitTests: XCTestCase {
    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "nothing service")

    func testReadSerial_ValidInput() throws {
        
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x0A]
        let result = try NothingServiceImpl.readSerial(hexArray: hexArray, logger: logger)
        XCTAssertEqual(result, "12345678901234567")
        
    }
    
    func testReadSerial_InvalidInput_LengthError() {
        
        let hexArray: [UInt8] = [0x00, 0x01, 0x02]
        XCTAssertThrowsError(try NothingServiceImpl.readSerial(hexArray: hexArray, logger: logger)) { error in
            XCTAssertEqual(error as? ArrayErrors, ArrayErrors.rangeError("hexArray length is less than 8"))
        }
    }
    
    func testReadSerial_NoSerialFound() throws {

        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x0A]
        _ = try NothingServiceImpl.readSerial(hexArray: hexArray, logger: logger)
      
    }
    
    func testReadSerial_Logging() throws {
        
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x0A]
        _ = try NothingServiceImpl.readSerial(hexArray: hexArray, logger: logger)
 
    }

}
