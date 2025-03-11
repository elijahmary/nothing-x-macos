//
//  JsonEncoder.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/2/25.
//

import Foundation
import os

class JsonEncoder {
    private let fileName: String
    private var devices: [String: NothingDeviceDTO] = [:] // Hashmap for MAC to device entity
    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "json encoder")
    
    static let shared = JsonEncoder(fileName: "configurations")
    
    private init(fileName: String) {
        self.fileName = fileName
        loadDevices()
    }
    
    // Load devices from the JSON file
    private func loadDevices() {
        let decoder = JSONDecoder()
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.error("Document directory not found.")
            return
        }
        
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).json")
        
        // Check if the file exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            // Create an empty JSON file
            createEmptyJsonFile(at: fileURL)
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let loadedDevices = try decoder.decode([NothingDeviceDTO].self, from: data)
            devices = Dictionary(uniqueKeysWithValues: loadedDevices.map { ($0.bluetoothDetails.mac, $0) }) // Convert to hashmap
        } catch {
            logger.error("Error loading devices: \(error.localizedDescription)")
        }
    }
    
    // Create an empty JSON file
    private func createEmptyJsonFile(at url: URL) {
        do {
            let emptyData = Data() // Empty data to write
            try emptyData.write(to: url) // Create the file
            logger.info("Created empty JSON file at \(url.path)")
        } catch {
            logger.error("Error creating empty JSON file: \(error.localizedDescription)")
        }
    }
    
    // Save devices to the JSON file
    private func saveDevices() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(Array(devices.values)) // Encode values of the hashmap
            let fileURL = getFileURL()
            try jsonData.write(to: fileURL)
            logger.info("Devices saved to \(fileURL.path)")
        } catch {
            logger.error("Error saving devices: \(error.localizedDescription)")
        }
    }
    
    // Add or update a device
    func addOrUpdateDevice(_ device: NothingDeviceDTO) {
        devices[device.bluetoothDetails.mac] = device // Add or update the device
        saveDevices()
    }
    
    // Delete a device by MAC address
    func deleteDevice(mac: String) {
        devices.removeValue(forKey: mac) // Remove the device from the hashmap
        saveDevices()
    }
    
    // Retrieve all devices
    func getAllDevices() -> [NothingDeviceDTO] {
        return Array(devices.values) // Return values as an array
    }
    
    // Helper function to get the file URL
    private func getFileURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent("\(fileName).json")
    }
}
