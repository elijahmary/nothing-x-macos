//
//  SwitchControlsUseCaseProtocol.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/8.
//

import Foundation

protocol SwitchControlsUseCaseProtocol {
    
    func switchGesture(device: GestureDeviceType, gesture: GestureType, action: UInt8)
    
}
