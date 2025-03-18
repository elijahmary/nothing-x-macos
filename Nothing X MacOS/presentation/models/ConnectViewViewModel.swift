//
//  ConnectViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/2/27.
//
import SwiftUI
import Foundation

class ConnectViewViewModel : ObservableObject {
    
    private let isBluetoothOnUseCase: IsBluetoothOnUseCaseProtocol
    private let connectToNothingUseCase: ConnectToNothingUseCaseProtocol
    private let getSavedDevicesUseCase: GetSavedDevicesUseCaseProtocol
    
    
    @Published var isLoading = false
    @Published var isFailedToConnectPresented = false
    @Published var retry = false
    @Published private(set) var isBluetoothOn = false
    
    
    
    init(isBluetoothOnUseCase: IsBluetoothOnUseCaseProtocol,
         connectToNothingUseCase: ConnectToNothingUseCaseProtocol,
         getSavedDevicesUseCase: GetSavedDevicesUseCaseProtocol) {
        
        self.isBluetoothOnUseCase = isBluetoothOnUseCase
        self.connectToNothingUseCase = connectToNothingUseCase
        self.getSavedDevicesUseCase = getSavedDevicesUseCase
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(NothingServiceNotifications.DATA_UPDATE_SUCCESS.rawValue),
            object: nil,
            queue: .main,
            using: handleDataUpdateSuccessNotification(_:)
            
        )
        
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(BluetoothNotifications.FAILED_TO_CONNECT.rawValue),
            object: nil,
            queue: .main,
            using: handleFailedToConnectNotification(_:)
        )
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(Notifications.REQUEST_RETRY.rawValue),
            object: nil,
            queue: .main,
            using: handleRequestRetryNotification(_:)
        )
        
    }
    
    @objc private func handleDataUpdateSuccessNotification(_ notification: Notification) {
        self.isLoading = false
    }
    
    @objc private func handleFailedToConnectNotification(_ notification: Notification) {
        withAnimation {
            self.isFailedToConnectPresented = true
            self.isLoading = false
        }
    }
    
    @objc private func handleRequestRetryNotification(_ notification: Notification) {
        connect()
        withAnimation {
            self.isFailedToConnectPresented = false
        }
    }
    
    func checkBluetoothStatus() {
        isBluetoothOn = isBluetoothOnUseCase.isBluetoothOn()
    }
    
    func connect() {
        isLoading = true
        let devices = getSavedDevicesUseCase.getSaved()
        
        connectToNothingUseCase.connectToNothing(device: devices[0].bluetoothDetails)
    }
    
    func navigateToBluetoothOffView() {
        
        NotificationCenter.default.post(name: Notification.Name(Notifications.APPEND_NAVIGATION_PATH.rawValue), object: Destination.bluetooth_off)
    }
    
    
    func retryConnect() {
        connect()
        retry = false
        withAnimation {
            isFailedToConnectPresented = false
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
