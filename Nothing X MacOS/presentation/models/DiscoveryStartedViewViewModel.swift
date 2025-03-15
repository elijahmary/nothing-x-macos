//
//  DiscoverStartedViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/9.
//

import Foundation
import SwiftUI
import Combine
class DiscoveryStartedViewViewModel : ObservableObject {
    
    private let discoverNothingUseCase: DiscoverNothingUseCaseProtocol
    private let connectToNothingUseCase: ConnectToNothingUseCaseProtocol
    private let isNothingConnectedUseCase: IsNothingConnectedUseCaseProtocol
    private let stopNothingDiscoveryUseCase: StopNothingDiscoveryUseCaseProtocol
    private let isBluetoothConnectedUseCase: IsBluetoothOnUseCaseProtocol
    
    private var discoveredDevice: BluetoothDeviceEntity? = nil
    
    @Published var viewState: DiscoverStates = .not_discovering
    
    @Published private(set) var deviceName: String = ""
    @Published private(set) var discoveryCirclesOffset: CGFloat = 0 //-60 when found
    @Published private(set) var shouldShowDevice = false
    @Published private(set) var shouldShowDiscoveryCircles = true
    @Published private(set) var shouldShowDiscoveryMessage = true
    @Published private(set) var shouldShowBudsBackground = false
    @Published private(set) var shouldShowDeviceName = false
    @Published private(set) var budsScale = 0.7
    @Published private(set) var budsOffsetY: CGFloat = 0 //32 when done
    @Published private(set) var budsOffsetX: CGFloat = 170 // 0 when done
    @Published private(set) var budsBackgroundsOffsetY: CGFloat = 0 //28 when done
    @Published private(set) var budsBackgroundOffsetX: CGFloat = 170 // 0 when done
    @Published private(set) var deviceNameOffsetX: CGFloat = 80
    @Published private(set) var deviceNameOffsetY: CGFloat = 30
    @Published private(set) var deviceNameFontSize: CGFloat = 12
    @Published private(set) var showSetUpButton = false
    @Published var shouldPresentModalSheet = false
    
    private var bluConnectivityCancellable: AnyCancellable?
    
    
    
    init(nothingService: NothingService, bluetoothService: BluetoothService ) {
        self.discoverNothingUseCase = DiscoverNothingUseCase(nothingService: nothingService)
        self.connectToNothingUseCase = ConnectToNothingUseCase(nothingService: nothingService)
        self.isNothingConnectedUseCase = IsNothingConnectedUseCase(nothingService: nothingService)
        self.stopNothingDiscoveryUseCase = StopNothingDiscoveryUseCase(nothingService: nothingService)
        self.isBluetoothConnectedUseCase = IsBluetoothOnUseCase(bluetoothService: bluetoothService)
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BluetoothNotifications.FOUND.rawValue), object: nil, queue: .main) { notification in
            
            if let bluetoothDevice = notification.object as? BluetoothDeviceEntity {
                
                
                print("Found device")
                if self.viewState != .found {
                    
                    self.viewState = .found
                    self.discoveredDevice = bluetoothDevice
                    var deviceName = bluetoothDevice.name
                    let components = deviceName.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                    
                    // Check if there are components after the first space
                    if components.count > 1 {
                        // Join the components after the first one
                        deviceName = components[1...].joined(separator: " ")
                    }
                    
                    self.deviceName = deviceName
          
                    self.objectWillChange.send()
                    withAnimation(.easeInOut(duration: 0.6)) {
                        
                        if self.discoveryCirclesOffset != -60 {
                            self.discoveryCirclesOffset = -60
                        }
                        if self.shouldShowBudsBackground != true {
                            self.shouldShowBudsBackground = true
                        }
                        if self.shouldShowDevice != true {
                            self.shouldShowDevice = true
                        }
                        
                        if self.shouldShowDeviceName != true {
                            self.shouldShowDeviceName = true
                        }
                    }
                    
                    withAnimation(.smooth(duration: 0.6)) {
                        self.budsOffsetX = 0
                        self.budsOffsetY = 32
                        self.budsBackgroundOffsetX = 0
                        self.budsBackgroundsOffsetY = 28
                    }
                }
                
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BluetoothNotifications.SEARCHING_COMPLETE.rawValue), object: nil, queue: .main) {
            notification in
            
            if (self.discoveredDevice == nil) {

                withAnimation {
                    self.viewState = .not_found
                    self.shouldPresentModalSheet = true
                }
                    
            }
            
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BluetoothNotifications.FAILED_TO_CONNECT.rawValue), object: nil, queue: .main) {
            notification in
            
            self.viewState = .failed_to_connect
        }
    

    }
    
    func startObservingBluConnectivity() {
        bluConnectivityCancellable = NotificationCenter.default
            .publisher(for: Notification.Name(BluetoothNotifications.BLUETOOTH_OFF.rawValue))
            .receive(on: RunLoop.main)
            .sink { notification in
                self.navigateToBluetoothOffView()
            }
    }
    
    func stopObservingBluConnectivity() {
        bluConnectivityCancellable?.cancel()
        bluConnectivityCancellable = nil
    }
    
    
    private func navigateToBluetoothOffView() {
        self.stopDiscovery()
        NotificationCenter.default.post(name: Notification.Name(Notifications.APPEND_NAVIGATION_PATH.rawValue), object: Destination.bluetooth_off)
    }
    
    func startDiscovery() {
        
        viewState = .discovering
        shouldPresentModalSheet = false
        discoverNothingUseCase.discoverNothing()
        
    }
    
    func stopObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func onDeviceSelectClick() {
        
        withAnimation() {
            shouldShowBudsBackground = false
            shouldShowDiscoveryMessage = false
            shouldShowDiscoveryCircles = false
            shouldShowDeviceName = false
        
        }
        
        withAnimation(.smooth(duration: 0.5)) {
            budsOffsetY = -30
            budsScale = 1.0
        }
        
        
        deviceNameOffsetX = 0
        deviceNameOffsetY = 48
        deviceNameFontSize = 16
        withAnimation(.smooth(duration: 0.6)) {
            shouldShowDeviceName = true
            showSetUpButton = true
        }
        
    }
    
    func connectToDevice() {
        
        withAnimation {
            viewState = .connecting
        }
      
        let connectedDevice: BluetoothDeviceEntity? = isNothingConnectedUseCase.isNothingConnected()
        
        if let discoveredDevice = discoveredDevice {
            if let connectedDevice = connectedDevice {
                if (connectedDevice.mac == discoveredDevice.mac) {
                    //fetch data and navigate to home screen
                    return
                }
            }
            connectToNothingUseCase.connectToNothing(device: discoveredDevice)
        }
        
    }
    
    func stopDiscovery() {
        stopNothingDiscoveryUseCase.stopNothingDiscovery()
    }
    
    deinit {
        stopObservers()
    }
    
}
