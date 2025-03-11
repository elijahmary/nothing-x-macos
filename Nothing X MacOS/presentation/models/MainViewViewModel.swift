//
//  MainViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/2/19.
//

import Foundation
import SwiftUI

class MainViewViewModel : ObservableObject {
    
    
    
    
    private let fetchDataUseCase: FetchDataUseCaseProtocol
    private let disconnectDeviceUseCase: DisconnectDeviceUseCaseProtocol
    private let getSavedDevicesUseCase: GetSavedDevicesUseCaseProtocol
    private let isBluetoothOnUseCase: IsBluetoothOnUseCaseProtocol
    private let isNothingConnectedUseCase: IsNothingConnectedUseCaseProtocol
    private let jsonEncoder: JsonEncoder = JsonEncoder.shared
    
    
    @Published private var rightBattery: Double? = nil
    @Published private var leftBattery: Double? = nil
    
    @Published private(set) var nothingDevice: NothingDeviceEntity?

    @Published var eqProfiles: EQProfiles = .BALANCED
    @Published var navigationPath: [Destination] = [.discover]
    
    @Published var leftTripleTapAction: TripleTapGestureActions = .NO_EXTRA_ACTION
    @Published var rightTripleTapAction: TripleTapGestureActions = .SKIP_BACK
    @Published var leftTapAndHoldAction: TapAndHoldGestureActions = .NO_EXTRA_ACTION
    @Published var rightTapAndHoldAction: TapAndHoldGestureActions = .NOISE_CONTROL
    
    @Published private(set) var batteryPercentage: String = ""
    
    
    
    init(
        fetchDataUseCase: FetchDataUseCaseProtocol,
        disconnectDeviceUseCase: DisconnectDeviceUseCaseProtocol,
        getSavedDevicesUseCase: GetSavedDevicesUseCaseProtocol,
        isBluetoothOnUseCase: IsBluetoothOnUseCaseProtocol,
        isNothingConnectedUseCase: IsNothingConnectedUseCaseProtocol
    
    ) {
        
        self.fetchDataUseCase = fetchDataUseCase
        self.disconnectDeviceUseCase = disconnectDeviceUseCase
        self.getSavedDevicesUseCase = getSavedDevicesUseCase
        self.isBluetoothOnUseCase = isBluetoothOnUseCase
        self.isNothingConnectedUseCase = isNothingConnectedUseCase
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BluetoothNotifications.CLOSED_RFCOMM_CHANNEL.rawValue), object: nil, queue: .main) {
            notification in
                        
            self.leftBattery = nil
            self.rightBattery = nil
            
            withAnimation {
                if self.getSavedDevicesUseCase.getSaved().isEmpty {
                    self.navigationPath.append(Destination.discover)
                } else {
                    self.navigationPath.append(Destination.connect)
                }
            }
  
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BluetoothNotifications.OPENED_RFCOMM_CHANNEL.rawValue), object: nil, queue: .main) {
            notification in
            
            self.fetchDataUseCase.fetchData()
            self.navigationPath.append(Destination.home)
        }
        
        
        NotificationCenter.default.addObserver(forName: Notification.Name(RepositoryNotifications.CONFIGURATION_DELETED.rawValue), object: nil, queue: .main) {
            notification in
            
            self.disconnectDeviceUseCase.disconnectDevice()
            
            self.navigationPath.append(Destination.discover)
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(DataNotifications.REPOSITORY_DATA_UPDATED.rawValue), object: nil, queue: .main) { notification in
            
#warning("if there is a device currently connected and you are trying to connect or discover another device at some point it might just snap to home screen")

            if let device = notification.object as? NothingDeviceEntity {
                self.nothingDevice = device
                withAnimation {
                    self.eqProfiles = device.listeningMode
                    self.rightTripleTapAction = device.tripleTapGestureActionRight
                    self.leftTripleTapAction = device.tripleTapGestureActionLeft
                    self.rightTapAndHoldAction = device.tapAndHoldGestureActionRight
                    self.leftTapAndHoldAction = device.tapAndHoldGestureActionLeft
                    self.batteryPercentage = self.calculateBatteryPercentage()
                }
                
                self.jsonEncoder.addOrUpdateDevice(device.toDTO())
                
                self.rightBattery = Double(device.rightBattery)
                self.leftBattery = Double(device.leftBattery)
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(Notifications.APPEND_NAVIGATION_PATH.rawValue), object: nil, queue: .main) { notification in
            
            if let path = notification.object as? Destination {
                self.navigationPath.append(path)
            }
        }

        
    
        // Check Bluetooth status and set the destination accordingly
        if !isBluetoothOnUseCase.isBluetoothOn() || !isNothingConnectedUseCase.isNothingConnected() {
            let devices = getSavedDevicesUseCase.getSaved()
            if (devices.isEmpty) {
                navigationPath = [.discover]
            } else {
                navigationPath = [.connect]
            }
        }
        
        
    }
    
    func navigateToBluetoothIsOff() {
        navigationPath.append(Destination.bluetooth_off)
    }
    

    private func calculateBatteryPercentage() -> String {
        // Check if both batteries are available
        var averageBattery = 0.0
        if let leftBattery = leftBattery {
            averageBattery = leftBattery
        }
        
        if let rightBattery = rightBattery {
            averageBattery = rightBattery
        }
        if let leftBattery = leftBattery, let rightBattery = rightBattery {
            // Calculate the average battery percentage
            averageBattery = (leftBattery + rightBattery) / 2.0
            // Format the result as a string with a percentage sign
        }
        return "\(Int(averageBattery))%"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
