//
//  BluetoothManager.swift
//  BluetoothTest
//
//  Created by Daniel on 2025/2/13.
//

import Foundation
import IOBluetooth
import CoreBluetooth
import os

class BluetoothManager: NSObject, IOBluetoothDeviceInquiryDelegate, IOBluetoothRFCOMMChannelDelegate, CBCentralManagerDelegate {

    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "bluetooth")
    
    static let shared = BluetoothManager()
    
    private var device: IOBluetoothDevice?
    private var rfcommChannel: IOBluetoothRFCOMMChannel?
    private var deviceInquiry: IOBluetoothDeviceInquiry?
    private lazy var deviceClass: UInt32? = nil
    
    private var centralManager: CBCentralManager!
    private var bluetoothState: BluetoothStates = .OFF
    
    
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothState = .ON
            logger.info("Bluetooth is on")
            NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.BLUETOOTH_ON.rawValue), object: nil)
            
        case .poweredOff:
            bluetoothState = .OFF
            logger.info("Bluetooth is off")
            NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.BLUETOOTH_OFF.rawValue), object: nil)
            
        case .resetting:
            logger.info("Bluetooth is resetting")
        case .unauthorized:
            logger.warning("Bluetooth is unauthorized")
        case .unsupported:
            logger.error("Bluetooth is unsupported")
        case .unknown:
            logger.error("Bluetooth state is unknown")
        @unknown default:
            logger.error("A previously unknown state occurred")
        }
    }
    
    func isBluetoothEnabled() -> Bool {
        return centralManager.state == .poweredOn
    }
    
    func isDeviceConnected() -> Bool {
        return device?.isConnected() ?? false
    }
    
    func getPaired(withClass: Int) -> [BluetoothDeviceEntity] {
        return IOBluetoothDevice.pairedDevices()
            .compactMap { $0 as? IOBluetoothDevice } // Safely unwrap and cast to IOBluetoothDevice
            .filter { $0.classOfDevice == withClass } // Filter by the specified device class
            .map { device in
                // Create an instance of BluetoothDevice
                BluetoothDeviceEntity(
                    name: device.name ?? "Unknown",
                    mac: device.addressString,
                    channelId: 15,
                    isPaired: true,
                    isConnected: device.isConnected()
                )
            }
    }
    
    func startDeviceInquiry(withClass: UInt32) {
        if deviceInquiry == nil {
            deviceInquiry = IOBluetoothDeviceInquiry(delegate: self)
            deviceInquiry?.start()
            deviceClass = withClass
            logger.info("Device discovery started.")
            NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.SEARCHING.rawValue), object: nil)
        }
    }
    
    func deviceInquiryComplete(_ sender: IOBluetoothDeviceInquiry!, error: IOReturn, aborted: Bool) {
        deviceInquiry = nil
        logger.info("Device discovery complete.")
        deviceClass = nil
        NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.SEARCHING_COMPLETE.rawValue), object: nil)
    }
    
    func deviceInquiryDeviceFound(_ sender: IOBluetoothDeviceInquiry!, device: IOBluetoothDevice!) {
        logger.info("Device found \(device.addressString)")
        
        if (device.classOfDevice == deviceClass) {
            let bluetoothDevice = BluetoothDeviceEntity(name: device.name, mac: device.addressString, channelId: 15, isPaired: false, isConnected: false)
            NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.FOUND.rawValue), object: bluetoothDevice)
        }
    }
    
    private func notifyConnectionSuccess() {
        
        if let device = device {
            
            self.logger.info("Connected to device")
            
            let bluetoothDevice = BluetoothDeviceEntity(name: device.name, mac: device.addressString, channelId: 15, isPaired: true, isConnected: true)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.CONNECTED.rawValue), object: bluetoothDevice)
            }
        }
    }
    
    
    func connectToDevice(address: String, channelID: UInt8) throws {
        
        guard address.isValidBluetoothMACAddress() else {
            
            throw Errors.invalidArgument("Provided mac address is invalid")
        }
        
        stopDeviceInquiry()
        
        if !isDeviceConnected() {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                self.logger.info("Connecting to device \(address)")
                
                self.device = IOBluetoothDevice(addressString: address)
                
                let result = self.device?.openConnection()
                if result == kIOReturnSuccess {
                    
                    self.notifyConnectionSuccess()
                } else {
                    
                    self.notifyConnectionFail()
                    return
                }
                
                self.attemptOpenRFCOMMChannel()
            }
        }
    }
    
    private func attemptOpenRFCOMMChannel() {
        
        if let device = device {
            let resultRFCOMM = device.openRFCOMMChannelAsync(&self.rfcommChannel, withChannelID: 15, delegate: self)
            
            if resultRFCOMM == kIOReturnSuccess {
                
                self.logger.info("Opened RFCOMM channel")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.OPENED_RFCOMM_CHANNEL.rawValue), object: nil)
                }
            } else {
                
                self.logger.error("Failed to open RFCOMM channel")
                self.device = nil
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.FAILED_RFCOMM_CHANNEL.rawValue), object: nil)
                }
            }
        }
    }
    
    fileprivate func notifyConnectionFail() {
        self.logger.error("Failed to connect to device")
        DispatchQueue.main.async {
            self.device = nil
            NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.FAILED_TO_CONNECT.rawValue), object: nil)
        }
    }
    
    func send(data: UnsafeMutableRawPointer!, length: UInt16) {
        rfcommChannel?.writeSync(data, length: length)
    }
    
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        // Create Data object from the received bytes
        let data = Data(bytes: dataPointer, count: dataLength)
        
        // Convert Data to [UInt8] (byte array)
        let rawData = [UInt8](data)
        
        NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.DATA_RECEIVED.rawValue), object: nil, userInfo: ["data": rawData])
    }
    
    func rfcommChannelClosed(_ channel: IOBluetoothRFCOMMChannel) {
        logger.info("RFCOMM channel closed.")
        self.device = nil
        self.rfcommChannel = nil
        NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.CLOSED_RFCOMM_CHANNEL.rawValue), object: nil)
    }
    
    func disconnectDevice() {
        if let channel = self.rfcommChannel {
            channel.close() // This should trigger rfcommChannelClosed delegate method
            self.rfcommChannel = nil // Ensure it's set to nil immediately
        }
        
        // Close the Connection to the Device
        if let device = self.device, device.isConnected() {
            device.closeConnection()
        }
        self.device = nil // Ensure it's set to nil immediately
        
        // Stop Device Inquiry (if running) - important to prevent further connections
        if let inquiry = self.deviceInquiry {
            inquiry.stop()
            self.deviceInquiry = nil
        }
        
        // Clear any stored device information
        device = nil
        rfcommChannel = nil
        
        // Post a Notification (optional, but good practice)
        NotificationCenter.default.post(name: Notification.Name(BluetoothNotifications.DISCONNECTED.rawValue), object: nil)
        
        logger.info("Disconnected from device.")
    }
    
    func stopDeviceInquiry() {
        deviceInquiry?.stop()
    }
    
}

extension String {
    
    func isValidBluetoothMACAddress() -> Bool {
        
        let macAddressPattern = "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
        let regex = try! NSRegularExpression(pattern: macAddressPattern, options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}
