//
//  FindMyBudsViewViewModel.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/2.
//

import Foundation

class FindMyBudsViewViewModel : ObservableObject {
    
    private let ringBudsUseCase: RingBudsUseCaseProtocol
    private let stopRingingBudsUseCase: StopRingingBudsUseCaseProtocol
    @Published var shouldShowWarning = false
    
    @Published var isRinging = false
    
    init(
        
        ringBudsUseCase: RingBudsUseCaseProtocol,
        stopRingingBudsUseCase: StopRingingBudsUseCaseProtocol
    ) {
        self.ringBudsUseCase = ringBudsUseCase
        self.stopRingingBudsUseCase = stopRingingBudsUseCase
    }
    
    
    func ringBuds() {
        isRinging = true
        shouldShowWarning = false
        ringBudsUseCase.ringBuds()
    }
    
    func stopRingingBuds() {
        isRinging = false
        stopRingingBudsUseCase.stopRingingBuds()
    }
    
    
}
