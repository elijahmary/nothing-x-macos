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
    
    
    init(nothingService: NothingService, nothingRepository: NothingRepository) {
        self.switchLatencyUseCase = SwitchLatencyUseCase(nothingService: nothingService)
        self.switchInEarDetectionUseCase = SwitchInEarDetectionUseCase(nothingService: nothingService)
        self.deleteSavedDeviceUseCase = DeleteSavedDeviceUseCase(nothingRepository: nothingRepository)
        self.getSavedDevicesUseCase = GetSavedDevicesUseCase(nothingRepository: nothingRepository)
        self.isNothingConnectedUseCase = IsNothingConnectedUseCase(nothingService: nothingService)
        
        
        NotificationCenter.default.addObserver(forName: Notification.Name(NothingServiceNotifications.DATA_UPDATE_SUCCESS.rawValue), object: nil, queue: .main) { notification in
            
            if let device = notification.object as? NothingDeviceEntity {
                self.updateDeviceDetails(device: device)
            }
        }
        
        isNothingDeviceAccessible = isNothingConnectedUseCase.isNothingConnected()
        
        setDeviceDetails()
        
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
