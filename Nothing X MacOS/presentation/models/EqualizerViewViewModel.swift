//
//  EqualizerViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/2/19.
//

import Foundation
import SwiftUI

class EqualizerViewViewModel : ObservableObject {
    
    
    private let switchEqUseCase: SwitchEqUseCaseProtocol
    
    @Published private(set) var eq: EQProfiles = .BALANCED
    
    init(switchEqUseCase: SwitchEqUseCaseProtocol) {
        
        self.switchEqUseCase = switchEqUseCase
        
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name(NothingServiceNotifications.DATA_UPDATE_SUCCESS.rawValue),
            object: nil,
            queue: .main,
            using: handleDataUpdateSuccessNotification(_ :)
            
            )
        
    }
    
    private func handleDataUpdateSuccessNotification(_ notification: Notification) {
        if let device = notification.object as? NothingDeviceEntity {
            withAnimation {
                
                if self.eq != device.listeningMode {
                    self.eq = device.listeningMode
                }
                
            }
            
        }
    }
    

    
    func switchEQ(eq: EQProfiles) {
    
        switchEqUseCase.switchEQ(mode: eq)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
