//
//  SettingsViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/3.
//

import Foundation

class SettingsViewViewModel : ObservableObject {
    
    private let switchLatencyUseCase: SwitchLatencyUseCaseProtocol
    private let switchInEarDetectionUseCase: SwitchInEarDetectionUseCaseProtocol
    private let deleteSavedDeviceUseCase: DeleteSavedUseCaseProtocol
    private let getSavedDevicesUseCase: GetSavedDevicesUseCaseProtocol
    private let isNothingConnectedUseCase: IsNothingConnectedUseCaseProtocol
    
    @Published var shouldShowForgetDialog = false
    @Published var latencySwitch = false
    @Published var inEarSwitch = false
    
    @Published private(set) var name: String = ""
    @Published private(set) var mac: String = ""
    @Published private(set) var serial: String = ""
    @Published private(set) var firmware: String = ""
    @Published private(set) var isNothingDeviceAccessible = false
    
    @Published private(set) var nothingDevice: NothingDeviceEntity?
    
    
    init(
        
        switchLatencyUseCase: SwitchLatencyUseCaseProtocol,
        switchInEarDetectionUseCase: SwitchInEarDetectionUseCaseProtocol,
        deleteSavedDeviceUseCase: DeleteSavedUseCaseProtocol,
        getSavedDevicesUseCase: GetSavedDevicesUseCaseProtocol,
        isNothingConnectedUseCase: IsNothingConnectedUseCaseProtocol
        
    ) {
        
        self.switchLatencyUseCase = switchLatencyUseCase
        self.switchInEarDetectionUseCase = switchInEarDetectionUseCase
        self.deleteSavedDeviceUseCase = deleteSavedDeviceUseCase
        self.getSavedDevicesUseCase = getSavedDevicesUseCase
        self.isNothingConnectedUseCase = isNothingConnectedUseCase
        
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(NothingServiceNotifications.DATA_UPDATE_SUCCESS.rawValue),
            object: nil,
            queue: .main,
            using: handleDataUpdateSuccessNotification(_:)
        )
        
        isNothingDeviceAccessible = isNothingConnectedUseCase.isNothingConnected()
        
        setDeviceDetails()
        
    }
    
    @objc private func handleDataUpdateSuccessNotification(_ notification: Notification) {
        
        if let device = notification.object as? NothingDeviceEntity {
            self.updateDeviceDetails(device: device)
        }
    }
    
    private func setDeviceDetails() {
        
        let devices = getSavedDevicesUseCase.getSaved()
        if (!devices.isEmpty) {
            name = devices[0].bluetoothDetails.name
            mac = devices[0].bluetoothDetails.mac
            serial = devices[0].serial
            firmware = devices[0].firmware
        }
    }
    
    private func updateDeviceDetails(device: NothingDeviceEntity) {
        self.latencySwitch = device.isLowLatencyOn
        
        self.inEarSwitch = device.isInEarDetectionOn
        self.nothingDevice = device
        
        self.name = device.bluetoothDetails.name
        self.mac = device.bluetoothDetails.mac
        self.serial = device.serial
        self.firmware = device.firmware
    }
    
    func switchLatency(mode: Bool) {
        
        switchLatencyUseCase.switchLatency(mode: mode)
    }
    
    func switchInEarDetection(mode: Bool) {
        switchInEarDetectionUseCase.switchInEarDetection(mode: mode)
    }
    
    func forgetDevice() {
        let devices = getSavedDevicesUseCase.getSaved()
        deleteSavedDeviceUseCase.delete(device: devices[0])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
