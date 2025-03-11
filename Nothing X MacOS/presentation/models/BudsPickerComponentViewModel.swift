//
//  BudsPickerComponentViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/8.
//

import Foundation
import SwiftUI
class BudsPickerComponentViewModel : ObservableObject {
    
    
    @Published var scaleButtonRight: CGFloat = 0.9
    @Published var scaleButtonLeft: CGFloat = 1.2
    @Published var isLeftDarken = false
    @Published var isRightDarken = true
    @Published var leftButtonOffset: CGFloat = 5
    @Published var rightButtonOffset: CGFloat = 5
    @Published var selectedBudText = "Left"
    @Published var selection: DeviceType = .LEFT {
        didSet {
            objectWillChange.send()
            animateSwitch()
        }
    }
    private func animateSwitch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if self.selection == .LEFT {
                    self.setAnimationProperties(isLeftDarken: false, isRightDarken: true, leftButtonOffset: 5, rightButtonOffset: 5, scaleButtonLeft: 1.2, scaleButtonRight: 0.9, selectedBudText: "Left")
                } else {
                    self.setAnimationProperties(isLeftDarken: true, isRightDarken: false, leftButtonOffset: -5, rightButtonOffset: -5, scaleButtonLeft: 0.9, scaleButtonRight: 1.2, selectedBudText: "Right")
                }
            }
        }
    }

    private func setAnimationProperties(isLeftDarken: Bool, isRightDarken: Bool, leftButtonOffset: CGFloat, rightButtonOffset: CGFloat, scaleButtonLeft: CGFloat, scaleButtonRight: CGFloat, selectedBudText: String) {
        self.isLeftDarken = isLeftDarken
        self.isRightDarken = isRightDarken
        self.leftButtonOffset = leftButtonOffset
        self.rightButtonOffset = rightButtonOffset
        self.scaleButtonLeft = scaleButtonLeft
        self.scaleButtonRight = scaleButtonRight
        self.selectedBudText = selectedBudText
    }
   
}
