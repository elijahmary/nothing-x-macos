//
//  NothingServiceParsers.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/14.
//

import Foundation
import os



extension NothingServiceImpl {
    
    static func readFirmware(hexArray: [UInt8], logger: Logger) -> String {
        
        let asciiLowerBound = 0x20
        let asciiUpperBound = 0x7E
        
        var firmwareVersion = ""
        let minArrLen = 9
        
        guard hexArray.count >= minArrLen else {
            logger.error("hexArray does not contain enough elements")
            return firmwareVersion
        }
        
        let firmwareLength = hexArray[5]
        let startingIndex = 8
        // Extract the firmware version based on the length
        for i in 0..<firmwareLength {
            let index = startingIndex + Int(i)
            
            if index < hexArray.count,
                hexArray[index] >= asciiLowerBound,
                hexArray[index] <= asciiUpperBound {
                
                firmwareVersion += String(UnicodeScalar(hexArray[index]))
            } else {
                logger.warning("Index \(index) is out of bounds for hexArray.")
                break
            }
        }
        
        return firmwareVersion
    }
    
    
    static func readLatencyMode(hexArray: [UInt8], logger: Logger) throws -> Bool {
        
        let minArrLen = 9
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        let latencyValueIndex = 8
        let lowLatencyOn = 1
        let lowLatencyOff = 2
        
        if hexArray[latencyValueIndex] == lowLatencyOn {
            return true
        } else if hexArray[latencyValueIndex] == lowLatencyOff {
            return false
        } else {
            throw Errors.invalidArgument("failed to parse latency mode")
        }
        
    }
    
    static func readANC(hexArray: [UInt8], logger: Logger) throws -> ANC {
        
        let minArrLen = 10
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        let ancValueIndex = 9
        let ancValue = hexArray[ancValueIndex]
        let mode = ANC(rawValue: ancValue)
        
        guard let mode = mode else {
            throw Errors.invalidArgument("failed to parse anc mode")
        }
        
        logger.info("ANC mode \(mode.rawValue)")
        
        return mode
    }
    
    static func readSerial(hexArray: [UInt8], logger: Logger) throws -> String {
        
        let minArrLen = 8
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        let startIndex = 7
        let requiredType = 4
        
        lazy var configurations: [(device: Int, type: Int, value: String)] = []
        
        // Decode the remaining payload and split by new lines
        let linesInBytes = hexArray[startIndex...] // Subarray from index 7 to the end
        let lines = String(decoding: linesInBytes, as: UTF8.self).split(separator: "\n")
        
        // Process each line
        for line in lines {
            let parts = line.split(separator: ",").map { String($0) }
            if parts.count == 3,
               let device = Int(parts[0]),
               let type = Int(parts[1]),
               let value = parts[2].nonEmpty {
                configurations.append((device: device, type: type, value: value))
            }
        }
        
        // Filter configurations to find the serial number
        let serialConfigs = configurations.filter { $0.type == requiredType && !$0.value.isEmpty }
        
        logger.info("Configurations:")
        for config in configurations {
            logger.info("Device: \(config.device), Type: \(config.type), Value: \(config.value)")
        }
        
        let serialValue = serialConfigs.first?.value ?? "12345678901234567"
        logger.info("Serial: \(serialValue)")
        return serialValue
    }
    
    static func readInEarDetection(hexArray: [UInt8], logger: Logger) throws -> Bool {
        
        let minArrLen = 11
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        let inEarValueIdx = 10
        
        logger.info("Read in-ear \(hexArray[inEarValueIdx] != 0)")
        return (hexArray[10] != 0)
    }
    
    static func readBattery(hexArray: [UInt8], logger: Logger) throws ->
    [(deviceType: BatteryDeviceType, batteryLevel: Int, isConnected: Bool, isCharging: Bool)] {
        
        var minArrLen = 9
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        let deviceCountIdx = 8
        var devices = 0
        
        let batteryMask: UInt8 = 127
        let chargingMask: UInt8 = 128
        
        let step = 2
        let idAccessIdx = 9
        let dataAccessIdx = 10
        
        devices = Int(hexArray[deviceCountIdx])
        
        minArrLen = dataAccessIdx + (devices - 1) * step
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        lazy var configurations: [(deviceType: BatteryDeviceType, batteryLevel: Int, isConnected: Bool, isCharging: Bool)] = [
            (deviceType: .LEFT, batteryLevel: 0, isConnected: false, isCharging: false),
            (deviceType: .RIGHT, batteryLevel: 0, isConnected: false, isCharging: false),
            (deviceType: .CASE, batteryLevel: 0, isConnected: false, isCharging: false)
        ]
    
        for i in 0..<devices {
            
            let offset = i * step
            
            let deviceId = hexArray[idAccessIdx + offset]
            let batteryData = hexArray[dataAccessIdx + offset]
            
            let batteryLevel = Int(batteryData & batteryMask)
            let isCharging = (batteryData & chargingMask) == chargingMask
            
            let deviceType = BatteryDeviceType(rawValue: deviceId)
            
            if let deviceType = deviceType, let index = configurations.firstIndex(where: {$0.deviceType == deviceType}) {

                configurations[index].batteryLevel = batteryLevel
                configurations[index].isCharging = isCharging
                configurations[index].isConnected = true
            }
            
        }
        
        for configuration in configurations {
            logger.info("Device: \(configuration.deviceType.rawValue), Battery level: \(configuration.batteryLevel), Charging: \(configuration.isCharging)")
        }
        
        return configurations
     
    }
    
    static func readEQ(hexArray: [UInt8], logger: Logger) throws -> EQProfiles {
        
        let minArrLen = 9
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        let eqValueIndex = 8
        let eqProfileValue: UInt8 = hexArray[eqValueIndex]
        logger.info("Read eqMode \(eqProfileValue)")

        let eqProfile = EQProfiles(rawValue: eqProfileValue)
        
        guard let eqProfile = eqProfile else {
            throw Errors.invalidArgument("failed to parse eq profile")
        }
        
        return eqProfile
    }
    
    static func readGestures(hexArray: [UInt8], logger: Logger) throws ->
    [(deviceType: GestureDeviceType, gestureType: GestureType, action: UInt8)] {
        
        lazy var configurations: [(deviceType: GestureDeviceType, gestureType: GestureType, action: UInt8)] = []
        
        var minArrLen = 9
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        let gestCountIdx = 8
        let gestCount: UInt8 = hexArray[gestCountIdx]
        
        let deviceAccessIdx = 9
        let gestAccessIdx = 11
        let actionAccessIdx = 12
        
        let step = 4
        
        minArrLen = gestAccessIdx + (Int(gestCount) - 1) * step
        try hexArray.isArrLenValid(arrLen: minArrLen)
        
        for i in 0..<gestCount {
            
            let offset = Int(i) * step
            
            let device = GestureDeviceType(rawValue: hexArray[deviceAccessIdx + offset])
//            _ = hexArray[10 + Int(i) * stride]
            let gesture = GestureType(rawValue: hexArray[gestAccessIdx + offset])
            let action = hexArray[actionAccessIdx + offset]
            
            if let device = device, let gesture = gesture {
                configurations.append((deviceType: device, gestureType: gesture, action: action))
            }
        }
        
        for configuration in configurations {
            logger.info("device \(configuration.0.rawValue) gesture \(configuration.1.rawValue) action \(configuration.2)")
        }
        
        return configurations
    }
    
}

extension [UInt8] {
    func isArrLenValid(arrLen: Int) throws {
        guard self.count >= arrLen else {
            throw ArrayErrors.rangeError("hexArray length is less than \(arrLen)")
        }
    }
}
