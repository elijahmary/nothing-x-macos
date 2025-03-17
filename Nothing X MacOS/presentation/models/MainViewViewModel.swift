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
    private let isLocalConfigEmptyUseCase: IsLocalConfigEmptyUseCaseProtocol
    private let jsonEncoder: JsonEncoder = JsonEncoder.shared
    
    
    @Published private var rightBattery: Double = 0.0
    @Published private var leftBattery: Double = 0.0
    @Published private var isLeftConnected = false
    @Published private var isRightConnected = false
    
    @Published private(set) var nothingDevice: NothingDeviceEntity?
    
    @Published var eqProfiles: EQProfiles = .BALANCED
    @Published var navigationPath: [Destination] = [.discover]
    
    @Published var leftTripleTapAction: TripleTapGestureActions = .NO_EXTRA_ACTION
    @Published var rightTripleTapAction: TripleTapGestureActions = .SKIP_BACK
    @Published var leftTapAndHoldAction: TapAndHoldGestureActions = .NO_EXTRA_ACTION
    @Published var rightTapAndHoldAction: TapAndHoldGestureActions = .NOISE_CONTROL
    
    @Published private(set) var batteryPercentage = String()
    
    
    
    init(
        fetchDataUseCase: FetchDataUseCaseProtocol,
        disconnectDeviceUseCase: DisconnectDeviceUseCaseProtocol,
        getSavedDevicesUseCase: GetSavedDevicesUseCaseProtocol,
        isBluetoothOnUseCase: IsBluetoothOnUseCaseProtocol,
        isNothingConnectedUseCase: IsNothingConnectedUseCaseProtocol,
        isLocalConfigEmptyUseCase: IsLocalConfigEmptyUseCaseProtocol
        
    ) {
        
        self.fetchDataUseCase = fetchDataUseCase
        self.disconnectDeviceUseCase = disconnectDeviceUseCase
        self.getSavedDevicesUseCase = getSavedDevicesUseCase
        self.isBluetoothOnUseCase = isBluetoothOnUseCase
        self.isNothingConnectedUseCase = isNothingConnectedUseCase
        self.isLocalConfigEmptyUseCase = isLocalConfigEmptyUseCase
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(BluetoothNotifications.CLOSED_RFCOMM_CHANNEL.rawValue),
            object: nil,
            queue: .main,
            using: handleRFCommChannelClosed(_:)
            
        )
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(BluetoothNotifications.OPENED_RFCOMM_CHANNEL.rawValue),
            object: nil,
            queue: .main,
            using: handleRFCommChannelOpened(_:)
            
        )
        
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name(RepositoryNotifications.CONFIGURATION_DELETED.rawValue),
            object: nil,
            queue: .main,
            using: handleConfigurationDeleted(_:)
        )
        
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(NothingServiceNotifications.DATA_UPDATE_SUCCESS.rawValue),
            object: nil,
            queue: .main,
            using: handleRepositoryDataUpdateSuccessNotification(_:)
            
        )
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name(Notifications.APPEND_NAVIGATION_PATH.rawValue),
            object: nil,
            queue: .main,
            using: handleAppendNavigationPath(_:)
        )
        
        setInitialView()

        
    }
    
#warning("if there is a device currently connected and you are trying to connect or discover another device at some point it might just snap to home screen")
    @objc private func handleRepositoryDataUpdateSuccessNotification(_ notification: Notification) {
        if let device = notification.object as? NothingDeviceEntity {
            self.nothingDevice = device
            withAnimation {
                self.eqProfiles = device.listeningMode
                self.rightTripleTapAction = device.tripleTapGestureActionRight
                self.leftTripleTapAction = device.tripleTapGestureActionLeft
                self.rightTapAndHoldAction = device.tapAndHoldGestureActionRight
                self.leftTapAndHoldAction = device.tapAndHoldGestureActionLeft
                self.rightBattery = Double(device.rightBattery)
                self.leftBattery = Double(device.leftBattery)
                self.isLeftConnected = device.isLeftConnected
                self.isRightConnected = device.isRightConnected
                self.batteryPercentage = self.calculateBatteryPercentage()
            }
            
            self.jsonEncoder.addOrUpdateDevice(device.toDTO())
            
        }
    }
    
    @objc private func handleRFCommChannelClosed(_ notification: Notification) {
        self.isLeftConnected = false
        self.isRightConnected = false
        self.batteryPercentage = String()
        
        withAnimation {
            if self.getSavedDevicesUseCase.getSaved().isEmpty {
                self.navigationPath.append(Destination.discover)
            } else {
                self.navigationPath.append(Destination.connect)
            }
        }
    }
    
    @objc private func handleRFCommChannelOpened(_ notification: Notification) {
        
        self.fetchDataUseCase.fetchData()
        self.navigationPath.append(Destination.home)
    }
    
    @objc private func handleConfigurationDeleted(_ notification: Notification) {
        
        self.disconnectDeviceUseCase.disconnectDevice()
        self.navigationPath.append(Destination.discover)
    }
    
    @objc private func handleAppendNavigationPath(_ notification: Notification) {
        
        if let path = notification.object as? Destination {
            self.navigationPath.append(path)
        }
    }
    
    private func setInitialView() {
        
        if !isNothingConnectedUseCase.isNothingConnected() {
            
            navigationPath =
            isLocalConfigEmptyUseCase.isEmpty()
            ? [.discover]
            : [.connect]
            
        } else {
            navigationPath = [.home]
        }
    }
    
    private func calculateBatteryPercentage() -> String {
        
        var averageBattery: Double
        
        if isLeftConnected || isRightConnected {
            
            averageBattery = (isLeftConnected ? leftBattery : 0) + (isRightConnected ? rightBattery : 0)
            averageBattery /= (isLeftConnected ? 1 : 0) + (isRightConnected ? 1 : 0)
        } else {
            
            averageBattery = 0.0
        }
        
        return "\(Int(averageBattery))%"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
