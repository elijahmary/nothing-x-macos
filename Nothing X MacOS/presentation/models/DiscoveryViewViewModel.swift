//
//  DiscoverViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/2/28.
//

import Foundation

class DiscoveryViewViewModel : ObservableObject {

    private let isBluetoothOnUseCase: IsBluetoothOnUseCaseProtocol
    @Published var destination: Destination = .discover_started
    
    
    private var discoveredDevice: BluetoothDeviceEntity? = nil
    
    init(isBluetoothOnUseCase: IsBluetoothOnUseCaseProtocol) {

        self.isBluetoothOnUseCase = isBluetoothOnUseCase
   
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BluetoothNotifications.BLUETOOTH_ON.rawValue), object: nil, queue: .main) {
            notification in
            
            self.destination = .discover_started
        }
        
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BluetoothNotifications.BLUETOOTH_OFF.rawValue), object: nil, queue: .main) {
            notification in
            
            self.destination = .bluetooth_off
        }
    }
    
    func checkBluetoothStatus() {
        
        if isBluetoothOnUseCase.isBluetoothOn() {
            destination = .discover_started
        } else {
            destination = .bluetooth_off
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
