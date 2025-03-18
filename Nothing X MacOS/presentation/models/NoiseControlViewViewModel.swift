//
//  HomeViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/2/18.
//

import Foundation
import SwiftUI

class NoiseControlViewViewModel : ObservableObject {
    
    private let switchAncUseCase: SwitchAncUseCaseProtocol
    
    @Published var noiseSelectionOffset: CGFloat = 61
    @Published var anc: NoiseControlOptions = .off
    
    init(switchAncUseCase: SwitchAncUseCaseProtocol) {
        
        self.switchAncUseCase = switchAncUseCase
        
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
                self.anc = self.ancToNoiseControlOptions(anc: device.anc)
                
                let offsetMapping: [NoiseControlOptions: CGFloat] = [
                    .off: 61,
                    .transparency: 0,
                    .anc: -61
                ]
                
                self.noiseSelectionOffset = offsetMapping[self.anc] ?? 61
            }
        }
    }
    
    
    func ancToNoiseControlOptions(anc: ANC) -> NoiseControlOptions {
        
        let actionMapping: [ANC: NoiseControlOptions] = [
            .OFF: .off,
            .TRANSPARENCY: .transparency,
            .ON_LOW: .anc,
            .ON_HIGH: .anc
        ]
        
        return actionMapping[anc] ?? .off
    }

    func noiseControlOptionsToAnc(option: NoiseControlOptions) -> ANC {
        
        let actionMapping: [NoiseControlOptions: ANC] = [
            .off: .OFF,
            .transparency: .TRANSPARENCY,
            .anc: .ON_LOW
        ]
        
        return actionMapping[option] ?? .OFF
    }
    
    func switchANC(anc: ANC) {
        switchAncUseCase.switchANC(mode: anc)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
