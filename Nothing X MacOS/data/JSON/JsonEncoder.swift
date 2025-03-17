//
//  JsonEncoder.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/2/25.
//

import Foundation
import os

class JsonEncoder {
    private let userDefaultsKey: String
    private lazy var devices: [String: NothingDeviceDTO] = [:] // Hashmap for MAC to device entity
    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "json encoder")
    
    static let shared = JsonEncoder(userDefaultsKey: "configurations")
    
    private init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        loadDevices()
    }
    
    // Load devices from UserDefaults
    private func loadDevices() {
        let decoder = JSONDecoder()
        
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            logger.info("No data found in UserDefaults for key: \(self.userDefaultsKey). Starting with an empty device list.")
            return
        }
        
        do {
            let loadedDevices = try decoder.decode([NothingDeviceDTO].self, from: data)
            devices = Dictionary(uniqueKeysWithValues: loadedDevices.map { ($0.bluetoothDetails.mac, $0) }) // Convert to hashmap
        } catch {
            logger.error("Error loading devices from UserDefaults: \(error.localizedDescription)")
        }
    }
    
    private func saveDevices() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(Array(devices.values))
            UserDefaults.standard.set(jsonData, forKey: userDefaultsKey)
            logger.info("Devices saved to UserDefaults with key: \(self.userDefaultsKey)")
        } catch {
            logger.error("Error saving devices to UserDefaults: \(error.localizedDescription)")
        }
    }
    
    func addOrUpdateDevice(_ device: NothingDeviceDTO) {
        devices[device.bluetoothDetails.mac] = device
        saveDevices()
    }
    
    func deleteDevice(mac: String) {
        devices.removeValue(forKey: mac)
        saveDevices()
    }
    
    func getAllDevices() -> [NothingDeviceDTO] {
        return Array(devices.values)
    }
    
    func isEmpty() -> Bool {
        return devices.isEmpty
    }
}
