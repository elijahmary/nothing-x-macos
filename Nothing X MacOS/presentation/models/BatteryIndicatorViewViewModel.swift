//
//  BatteryIndicatorViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/2/18.
//

import Foundation
import SwiftUI


class BatteryIndicatorViewViewModel : ObservableObject {
    
    @Published private(set) var leftBattery: Int = 0;
    @Published private(set) var rightBattery: Int = 0;
    @Published private(set) var caseBattery: Int = 0;
    @Published private(set) var isLeftCharging = false;
    @Published private(set) var isRightCharging = false;
    @Published private(set) var isCaseCharging = false;
    @Published private(set) var isLeftConnected = false;
    @Published private(set) var isRightConnected = false;
    @Published private(set) var isCaseConnected = true;
    
    init() {
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name(NothingServiceNotifications.DATA_UPDATE_SUCCESS.rawValue),
            object: nil,
            queue: .main,
            using: handleDataUpdateSuccessNotification(_:)
        )
    }
    
    
    
    @objc private func handleDataUpdateSuccessNotification(_ notification: Notification) {
        if let device = notification.object as? NothingDeviceEntity {
            
            
            setBatteryPercentage(newLeftBattery: device.leftBattery, newRightBattery: device.rightBattery, newCaseBattery: device.caseBattery)
            
            setChargingState(newIsLeftCharging: device.isLeftCharging, newIsRightCharging: device.isRightCharging, newIsCaseCharging: device.isCaseCharging)
            
            setVisibilityState(newIsLeftConnected: device.isLeftConnected, newIsRightConnected: device.isRightConnected, newIsCaseConnected: device.isCaseConnected)
            
        }
    }
    
    private func setBatteryPercentage(newLeftBattery: Int, newRightBattery: Int, newCaseBattery: Int) {
        
        if self.leftBattery != newLeftBattery {
            self.leftBattery = newLeftBattery
        }
        
        if self.caseBattery != newCaseBattery {
            self.caseBattery = newCaseBattery
        }
        
        if self.rightBattery != newRightBattery {
            self.rightBattery = newRightBattery
        }
    }
    
    private func setChargingState(newIsLeftCharging: Bool, newIsRightCharging: Bool, newIsCaseCharging: Bool) {
        if self.isRightCharging != newIsLeftCharging {
            withAnimation {
                self.isRightCharging = newIsLeftCharging
            }
        }
        
        if self.isLeftCharging != newIsLeftCharging {
            withAnimation {
                self.isLeftCharging = newIsLeftCharging
            }
        }
        
        if self.isCaseCharging != newIsCaseCharging {
            withAnimation {
                self.isCaseCharging = newIsCaseCharging
            }
        }
    }
    
    private func setVisibilityState(newIsLeftConnected: Bool, newIsRightConnected: Bool, newIsCaseConnected: Bool) {
        if self.isRightConnected != newIsRightConnected{
            withAnimation {
                self.isRightConnected = newIsRightConnected
            }
            
        }
        
        if self.isLeftConnected != newIsLeftConnected {
            withAnimation {
                self.isLeftConnected = newIsLeftConnected
            }
            
        }
        
        if self.isCaseConnected != newIsCaseConnected{
            withAnimation {
                self.isCaseConnected = newIsCaseConnected
            }
            
        }
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
