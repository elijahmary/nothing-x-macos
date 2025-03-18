//
//  DiscoverStartedViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/9.
//

import Foundation
import SwiftUI
import Combine
import os
class DiscoveryStartedViewViewModel : ObservableObject {
    
    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "discovery started")
    
    private let discoverNothingUseCase: DiscoverNothingUseCaseProtocol
    private let connectToNothingUseCase: ConnectToNothingUseCaseProtocol
    private let isNothingConnectedUseCase: IsNothingConnectedUseCaseProtocol
    private let stopNothingDiscoveryUseCase: StopNothingDiscoveryUseCaseProtocol
    private let isBluetoothConnectedUseCase: IsBluetoothOnUseCaseProtocol
    
    private var discoveredDevice: BluetoothDeviceEntity? = nil
    private var bluConnectivityCancellable: AnyCancellable?
    
    @Published private(set) var viewState: DiscoverStates = .not_discovering
    
    @Published private(set) var shouldShowDevice = false
    @Published private(set) var shouldShowDiscoveryCircles = true
    @Published private(set) var shouldShowDiscoveryMessage = true
    @Published private(set) var shouldShowBudsBackground = false
    @Published private(set) var shouldShowDeviceName = false
    @Published private(set) var shouldShowSetUpButton = false
    @Published var shouldPresentModalSheet = false
    
    @Published private(set) var discoveryCirclesOffset: CGFloat = 0 //-60 when found
    @Published private(set) var budsScale = 0.7
    @Published private(set) var budsOffsetY: CGFloat = 0 //32 when done
    @Published private(set) var budsOffsetX: CGFloat = 170 // 0 when done
    @Published private(set) var budsBackgroundsOffsetY: CGFloat = 0 //28 when done
    @Published private(set) var budsBackgroundOffsetX: CGFloat = 170 // 0 when done
    @Published private(set) var deviceNameOffsetX: CGFloat = 80
    @Published private(set) var deviceNameOffsetY: CGFloat = 30
    @Published private(set) var deviceNameFontSize: CGFloat = 12
    @Published private(set) var deviceName: String = String()


    init(
        discoverNothingUseCase: DiscoverNothingUseCaseProtocol,
        connectToNothingUseCase: ConnectToNothingUseCaseProtocol,
        isNothingConnectedUseCase: IsNothingConnectedUseCaseProtocol,
        stopNothingDiscoveryUseCase: StopNothingDiscoveryUseCaseProtocol,
        isBluetoothConnectedUseCase: IsBluetoothOnUseCaseProtocol
    ) {
        
        self.discoverNothingUseCase = discoverNothingUseCase
        self.connectToNothingUseCase = connectToNothingUseCase
        self.isNothingConnectedUseCase = isNothingConnectedUseCase
        self.stopNothingDiscoveryUseCase = stopNothingDiscoveryUseCase
        self.isBluetoothConnectedUseCase = isBluetoothConnectedUseCase
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(BluetoothNotifications.FOUND.rawValue),
            object: nil,
            queue: .main,
            using: handleDeviceFoundNotification(_:)
        )
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(BluetoothNotifications.SEARCHING_COMPLETE.rawValue),
            object: nil,
            queue: .main,
            using: handleSearchCompleteNotification(_:)
        )
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name(BluetoothNotifications.FAILED_TO_CONNECT.rawValue),
            object: nil,
            queue: .main,
            using: handleFailedToConnectNotification(_:)
        )
        
        
    }
    
    @objc private func handleDeviceFoundNotification(_ notification: Notification) {
        
        if let bluetoothDevice = notification.object as? BluetoothDeviceEntity,  self.viewState != .found {
            
            self.viewState = .found
            self.discoveredDevice = bluetoothDevice
            
            self.deviceName = prepareDeviceName(name: bluetoothDevice.name)
            
            self.objectWillChange.send()
            
            withAnimation(.easeInOut(duration: 0.6)) {
                
                moveCirclesToPositionDiscovered()
                showDiscoveredDevice()
            }
            
            moveBudsToPositionDiscovered()
            
        }
    }
    
    @objc private func handleSearchCompleteNotification(_ notification: Notification) {
        
        if (self.discoveredDevice == nil) {
            
            withAnimation {
                self.viewState = .not_found
                self.shouldPresentModalSheet = true
                
                showDiscoveredDevice()
            }
            
        }
    }
    
    @objc private func handleFailedToConnectNotification(_ notification: Notification) {
        self.viewState = .failed_to_connect
    }
    
    func startObservingBluConnectivity() {
        
        bluConnectivityCancellable = NotificationCenter.default
            .publisher(for: Notification.Name(BluetoothNotifications.BLUETOOTH_OFF.rawValue))
            .receive(on: RunLoop.main)
            .sink { notification in
                self.logger.debug("In DiscoveryStartedViewModel: navigating to bluetooth off view")
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
    
    private func showDiscoveredDevice() {
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
    
    private func moveCirclesToPositionDiscovered() {
        
        if self.discoveryCirclesOffset != -60 {
            self.discoveryCirclesOffset = -60
        }
    }
    
    private func prepareDeviceName(name: String) -> String {
        
        let components = name.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        var resultName = name
        
        if components.count > 1 {
            // Join the components after the first one
            resultName = components[1...].joined(separator: " ")
        }
        
        return resultName
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
        
        hideDiscoveryElements()
        
        moveBudsToPositionSelected()
        
        moveDeviceNameToPositionSelected()
        
        withAnimation(.smooth(duration: 0.6)) {
            
            showDeviceName()
            showSetUpButton()
        }
        
    }
    
    private func hideDiscoveryElements() {
        withAnimation() {
            shouldShowBudsBackground = false
            shouldShowDiscoveryMessage = false
            shouldShowDiscoveryCircles = false
            shouldShowDeviceName = false
        }
    }
    
    
    private func moveBudsToPositionSelected() {
        withAnimation(.smooth(duration: 0.5)) {
            budsOffsetY = -30
            budsScale = 1.0
        }
    }
    
    private func moveDeviceNameToPositionSelected() {
        deviceNameOffsetX = 0
        deviceNameOffsetY = 48
        deviceNameFontSize = 16
    }
    
    private func moveBudsToPositionDiscovered() {
        withAnimation(.smooth(duration: 0.6)) {
            self.budsOffsetX = 0
            self.budsOffsetY = 32
            self.budsBackgroundOffsetX = 0
            self.budsBackgroundsOffsetY = 28
        }
        
    }
    
    private func showDeviceName() {
        shouldShowDeviceName = true
    }
    
    private func showSetUpButton() {
        shouldShowSetUpButton = true
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
