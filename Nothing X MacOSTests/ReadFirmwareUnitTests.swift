//
//  ReadFirmwareUnitTests.swift
//  Nothing X MacOSTests
//
//  Created by Daniel on 2025/3/14.
//

import XCTest
@testable import Nothing_X_MacOS
import os

final class ReadFirmwareUnitTests: XCTestCase {

    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "nothing service")
    override func setUpWithError() throws {
        
    }
    
    func testReadFirmware_ValidInput() {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x03, 0x00, 0x00, 0x46, 0x69, 0x72]
        let result = NothingServiceImpl.readFirmware(hexArray: hexArray, logger: logger)
        XCTAssertEqual(result, "Fir")
    }
    
    func testReadFirmware_InsufficientLength() {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02]
        let result = NothingServiceImpl.readFirmware(hexArray: hexArray, logger: logger)
        XCTAssertEqual(result, "")
    }
    
    func testReadFirmware_OutOfBounds() {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x00, 0x00, 0x05, 0x41, 0x42]
        let result = NothingServiceImpl.readFirmware(hexArray: hexArray, logger: logger)
        XCTAssertEqual(result, "")
        
    }
    
    func testReadFirmware_EmptyArray() {
        let hexArray: [UInt8] = []
        let result = NothingServiceImpl.readFirmware(hexArray: hexArray, logger: logger)
        XCTAssertEqual(result, "")
    }
    
    func testReadFirmware_UIntOutOfRange() {
        let hexArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        let result = NothingServiceImpl.readFirmware(hexArray: hexArray, logger: logger)
        XCTAssertEqual(result, "")
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
