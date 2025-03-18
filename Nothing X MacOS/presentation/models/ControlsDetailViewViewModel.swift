//
//  ControlsDetailViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/9.
//

import Foundation
class ControlsDetailViewViewModel : ObservableObject {
    
    private let switchControlsUseCase: SwitchControlsUseCaseProtocol

    
    init(switchControlsUseCase: SwitchControlsUseCaseProtocol) {
        self.switchControlsUseCase = switchControlsUseCase
    }
    

    func switchTripleTapAction(device: GestureDeviceType, action: TripleTapOptions) {
        
        let actionMapping: [TripleTapOptions: TripleTapGestureActions] = [
            .no_action: .NO_EXTRA_ACTION,
            .skip_back: .SKIP_BACK,
            .skip_forward: .SKIP_FORWARD,
            .voice_assistant: .VOICE_ASSISTANT
        ]
        
        let convertedAction = actionMapping[action] ?? .NO_EXTRA_ACTION
        
        switchControlsUseCase.switchGesture(device: device, gesture: .TRIPLE_TAP, action: convertedAction.rawValue)
    }
    
    func switchTapAndHoldAction(device: GestureDeviceType, action: TapAndHoldOptions) {
        
        let actionMapping: [TapAndHoldOptions: TapAndHoldGestureActions] = [
            .no_extra_action: .NO_EXTRA_ACTION,
            .noise_control: .NOISE_CONTROL
        ]
        
        let convertedAction = actionMapping[action] ?? .NO_EXTRA_ACTION
        
        switchControlsUseCase.switchGesture(device: device, gesture: .TAP_AND_HOLD, action: convertedAction.rawValue)
    }
    
    func convertTripleTapActionToOption(action: TripleTapGestureActions) -> TripleTapOptions {
        
        let actionMapping: [TripleTapGestureActions: TripleTapOptions] = [
            .NO_EXTRA_ACTION: .no_action,
            .SKIP_BACK: .skip_back,
            .SKIP_FORWARD: .skip_forward,
            .VOICE_ASSISTANT: .voice_assistant
        ]
        
        return actionMapping[action] ?? .no_action
    }

    func convertTapAndHoldActionToOption(action: TapAndHoldGestureActions) -> TapAndHoldOptions {
        
        let actionMapping: [TapAndHoldGestureActions: TapAndHoldOptions] = [
            .NOISE_CONTROL: .noise_control,
            .NO_EXTRA_ACTION: .no_extra_action
        ]
        
        return actionMapping[action] ?? .no_extra_action
    }
    
}
